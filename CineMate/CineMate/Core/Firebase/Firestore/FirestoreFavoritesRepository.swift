//
//  FirestoreFavoritesRepository.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-09.
//

import Foundation
import FirebaseFirestore

/// Reads/writes a user's **favorite movies** in Firestore.
/// Uses a lazy Firestore handle to keep previews lightweight.
final class FirestoreFavoritesRepository {

    /// Optional injected Firestore; falls back to `Firestore.firestore()`.
    private var _firestore: Firestore?

    /// Designated initializer.
    /// - Parameter firestore: Custom Firestore for testing/overrides.
    init(firestore: Firestore? = nil) { self._firestore = firestore }

    /// Active Firestore instance (lazy default).
    private var firestore: Firestore { _firestore ?? Firestore.firestore() }

    /// Adds or updates a favorite movie document.
    /// - Parameters:
    ///   - movie: Movie to persist (id used as doc ID).
    ///   - uid: Owner's user ID.
    func addFavorite(movie: Movie, for uid: String) async throws {
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

        try await firestore
            .collection("users").document(uid)
            .collection("favorites").document(String(movie.id))
            .setData(data, merge: true)
    }

    /// Removes a favorite movie document.
    /// - Parameters:
    ///   - id: TMDB movie ID.
    ///   - uid: Owner's user ID.
    func removeFavorite(id: Int, for uid: String) async throws {
        try await firestore
            .collection("users").document(uid)
            .collection("favorites").document(String(id))
            .delete()
    }

    /// Live stream of a user's favorite movies ordered by newest first.
    /// - Parameter uid: Owner's user ID.
    /// - Returns: Async stream emitting full lists on every change.
    func favoritesStream(for uid: String) -> AsyncStream<[Movie]> {
        AsyncStream { continuation in
            let query = firestore
                .collection("users").document(uid)
                .collection("favorites")
                .order(by: "createdAt", descending: true)

            let listener = query.addSnapshotListener { snapshot, error in
                if let error = error {
                    print("favoritesStream error:", error)
                    continuation.finish()
                    return
                }
                let movies = snapshot?.documents.compactMap(Self.mapToMovie(doc:)) ?? []
                continuation.yield(movies)
            }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    /// Maps a Firestore document to a `Movie` (lenient on optionals).
    /// - Parameter doc: Firestore document.
    /// - Returns: Movie or `nil` if required fields are missing.
    private static func mapToMovie(doc: DocumentSnapshot) -> Movie? {
        let d = doc.data() ?? [:]
        guard let id = d["id"] as? Int, let title = d["title"] as? String else { return nil }
        return Movie(
            id: id,
            title: title,
            overview: d["overview"] as? String,
            posterPath: d["posterPath"] as? String,
            backdropPath: nil,
            releaseDate: d["releaseDate"] as? String,
            voteAverage: d["voteAverage"] as? Double,
            genres: d["genres"] as? [String]
        )
    }
}
