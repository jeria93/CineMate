//
//  FirestoreFavoritePeopleRepository.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-11.
//

import Foundation
import FirebaseFirestore

/// # FirestoreFavoritePeopleRepository
/// Handles reading and writing user's favorite people (actors/directors) in Firestore.
final class FirestoreFavoritePeopleRepository {

    /// Firestore database instance.
    private let firestore: Firestore

    /// Creates a new repository instance.
    /// - Parameter firestore: Optional Firestore instance (defaults to shared).
    init(firestore: Firestore = .firestore()) {
        self.firestore = firestore
    }

    /// Streams favorite people in real time for the given user.
    /// - Parameter uid: Firebase Auth user ID.
    /// - Returns: AsyncStream emitting `[PersonRef]` on each change.
    func favoritePeopleStream(uid: String) -> AsyncStream<[PersonRef]> {
        AsyncStream { continuation in
            // Query: user's favorite people sorted by newest first
            let query = FirestorePaths.userFavoritePeople(uid: uid)
                .order(by: "createdAt", descending: true)

            // Attach snapshot listener
            let listener = query.addSnapshotListener { snapshot, error in
                if let error = error {
                    print("favoritePeopleStream error:", error)
                    continuation.finish()
                    return
                }

                // Map documents to PersonRef models
                let people: [PersonRef] = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    guard let id = data["id"] as? Int,
                          let name = data["name"] as? String else { return nil }
                    return PersonRef(
                        id: id,
                        name: name,
                        profilePath: data["profilePath"] as? String
                    )
                } ?? []

                // Emit the latest array
                continuation.yield(people)
            }

            // Remove listener when stream ends
            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }

    /// Adds or updates a person in the user's favorites.
    /// - Parameters:
    ///   - person: The `PersonRef` to save.
    ///   - uid: Firebase Auth user ID.
    func addFavorite(person: PersonRef, uid: String) async throws {
        try await firestore
            .collection("users").document(uid)
            .collection("favorite_people").document("\(person.id)")
            .setData([
                "id": person.id,
                "name": person.name,
                "profilePath": person.profilePath as Any,
                "createdAt": FieldValue.serverTimestamp()
            ], merge: true)
    }

    /// Removes a person from the user's favorites.
    /// - Parameters:
    ///   - id: TMDB person ID to remove.
    ///   - uid: Firebase Auth user ID.
    func removeFavorite(id: Int, uid: String) async throws {
        try await firestore
            .collection("users").document(uid)
            .collection("favorite_people").document("\(id)")
            .delete()
    }
}
