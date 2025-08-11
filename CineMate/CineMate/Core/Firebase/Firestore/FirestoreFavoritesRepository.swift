//
//  FirestoreFavoritesRepository.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-09.
//

import Foundation
import FirebaseFirestore

/// Repository for persisting and fetching a user's favorite movies
/// from **Cloud Firestore** in the CineMate app.
///
/// **Firestore Path Layout:**
/// ```
/// users/{uid}/favorites/{movieId}
/// ```
///
/// ## Responsibilities
/// 1. Add (upsert) a movie to a user’s favorites.
/// 2. Remove a movie from a user’s favorites.
/// 3. List all favorites for a user (ordered by newest first).
/// 4. Provide a real-time stream of favorites for a user.
/// 5. Centralize Firestore path handling via `FirestorePaths`.
///
/// ## Usage
/// ```swift
/// let repo = FirestoreFavoritesRepository()
///
/// // Add a favorite
/// try await repo.addFavorite(movie, for: uid)
///
/// // List all favorites
/// let favorites = try await repo.listFavorites(for: uid)
///
/// // Remove a favorite
/// try await repo.removeFavorite(id: movie.id, for: uid)
///
/// // Stream favorites in real-time
/// for await movies in repo.favoritesStream(for: uid) {
///     print(movies)
/// }
/// ```
///
/// **Notes:**
/// - Uses TMDB `movie.id` as the Firestore document ID (stringified).
/// - Writes a `createdAt` server timestamp to support “recently favorited” sorting.
/// - Mapping is lenient: only `id` and `title` are required for UI rendering.
///
final class FirestoreFavoritesRepository {

    // MARK: - Dependencies

    /// Firestore database handle. Injected for testability and flexibility.
    private let firestore: Firestore

    /// Creates a new repository instance.
    /// - Parameter firestore: Optional Firestore instance (defaults to the shared singleton).
    init(firestore: Firestore = .firestore()) {
        self.firestore = firestore
    }

    // MARK: - Public API

    /// Adds (or updates) a movie in the user's favorites collection.
    ///
    /// - Parameters:
    ///   - movie: The `Movie` to save. `movie.id` becomes the document ID.
    ///   - uid: The Firebase Auth user ID that owns the favorites.
    /// - Throws: Firestore errors if the write fails.
    func addFavorite(movie: Movie, for uid: String) async throws {
        // Path: users/{uid}/favorites
        let collection = FirestorePaths.userFavorites(uid: uid)
        let document = collection.document(String(movie.id)) // Firestore doc IDs are strings

        // Required + optional fields for the favorite entry
        var data: [String: Any] = [
            "id": movie.id,
            "title": movie.title,
            "createdAt": FieldValue.serverTimestamp()
        ]
        if let posterPath = movie.posterPath { data["posterPath"] = posterPath }
        if let releaseDate = movie.releaseDate { data["releaseDate"] = releaseDate }
        if let voteAverage = movie.voteAverage { data["voteAverage"] = voteAverage }
        if let genres = movie.genres { data["genres"] = genres }
        if let overview = movie.overview { data["overview"] = overview }

        // Merge to avoid overwriting existing fields unnecessarily
        try await document.setData(data, merge: true)
    }

    /// Removes a movie from the user's favorites.
    ///
    /// - Parameters:
    ///   - id: TMDB movie ID to remove.
    ///   - uid: The Firebase Auth user ID that owns the favorites.
    /// - Throws: Firestore errors if the deletion fails.
    func removeFavorite(id: Int, for uid: String) async throws {
        let collection = FirestorePaths.userFavorites(uid: uid)
        try await collection.document(String(id)).delete()
    }


    /// Provides a real-time stream of favorite movies for the given user.
    ///
    /// - Parameter uid: The Firebase Auth UID of the user.
    /// - Returns: `AsyncStream<[Movie]>` emitting a new array whenever
    ///   the Firestore collection changes (add / remove / update).
    ///
    /// The stream ends if:
    /// - A Firestore error occurs (e.g., permission denied, invalid index, auth issue).
    /// - The consumer cancels the stream (e.g., view disappears).
    func favoritesStream(for uid: String) -> AsyncStream<[Movie]> {
        AsyncStream { continuation in
            // 1) Create a Firestore query sorted by newest first
            let query = FirestorePaths.userFavorites(uid: uid)
                .order(by: "createdAt", descending: true)

            // 2) Attach a real-time listener
            let listener = query.addSnapshotListener { snapshot, error in
                if let error = error {
                    // Finish the stream on error to avoid hanging listeners
                    print("favoritesStream error:", error)
                    continuation.finish()
                    return
                }

                // 3) Map documents to Movie models
                let movies = snapshot?.documents.compactMap(Self.mapToMovie(doc:)) ?? []

                // 4) Emit the latest complete list to consumers
                continuation.yield(movies)
            }

            // 5) Clean up listener when the consumer stops the stream
            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }

    // MARK: - Mapping

    /// Converts a Firestore document into a `Movie` instance.
    /// - Requires `id` (Int) and `title` (String).
    /// - Optional properties are included if available.
    ///
    /// - Parameter doc: A Firestore document snapshot.
    /// - Returns: A `Movie` object or `nil` if required fields are missing.

//    You could also test to do DTO instead of mapping the Movie
    private static func mapToMovie(doc: DocumentSnapshot) -> Movie? {
        let data = doc.data() ?? [:]

        guard let id = data["id"] as? Int,
              let title = data["title"] as? String else {
            return nil
        }

        let posterPath = data["posterPath"] as? String
        let releaseDate = data["releaseDate"] as? String
        let voteAverage = data["voteAverage"] as? Double
        let genres = data["genres"] as? [String]
        let overview = data["overview"] as? String

        return Movie(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: nil,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            genres: genres
        )
    }
}
