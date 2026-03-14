//
//  FirestoreFavoritePeopleRepository.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-11.
//

import Foundation
import FirebaseFirestore

/// Reads/writes a user's **favorite people** (actors/directors) in Firestore.
/// Lazy Firestore handle to keep design-time flows light.
final class FirestoreFavoritePeopleRepository {

    /// Optional injected Firestore; falls back to shared instance.
    private var _firestore: Firestore?

    /// Designated initializer.
    /// - Parameter firestore: Custom Firestore for testing/overrides.
    init(firestore: Firestore? = nil) { self._firestore = firestore }

    /// Active Firestore instance (lazy default).
    private var firestore: Firestore { _firestore ?? Firestore.firestore() }

    /// Live stream of a user's favorite people ordered by newest first.
    /// - Parameter uid: Owner's user ID.
    /// - Returns: Async stream emitting full lists on every change.
    func favoritePeopleStream(uid: String) -> AsyncThrowingStream<[PersonRef], Error> {
        AsyncThrowingStream { continuation in
            let query = FirestorePaths
                .userFavoritePeople(uid: uid, in: firestore)
                .order(by: "createdAt", descending: true)

            let listener = query.addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                let people = snapshot?.documents.compactMap(Self.mapToPerson(doc:)) ?? []
                continuation.yield(people)
            }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    /// Adds or updates a favorite person document.
    /// - Parameters:
    ///   - person: Person to persist.
    ///   - uid: Owner's user ID.
    func addFavorite(person: PersonRef, uid: String) async throws {
        try await FirestorePaths
            .userFavoritePeople(uid: uid, in: firestore)
            .document("\(person.id)")
            .setData([
                "id": person.id,
                "name": person.name,
                "profilePath": person.profilePath as Any,
                "createdAt": FieldValue.serverTimestamp()
            ], merge: true)
    }

    /// Removes a favorite person document.
    /// - Parameters:
    ///   - id: TMDB person ID.
    ///   - uid: Owner's user ID.
    func removeFavorite(id: Int, uid: String) async throws {
        try await FirestorePaths
            .userFavoritePeople(uid: uid, in: firestore)
            .document("\(id)")
            .delete()
    }

    private static func mapToPerson(doc: QueryDocumentSnapshot) -> PersonRef? {
        let data = doc.data()
        let fallbackID = Int(doc.documentID)
        guard let id = intValue(from: data["id"]) ?? fallbackID,
              let name = data["name"] as? String else { return nil }

        return PersonRef(
            id: id,
            name: name,
            profilePath: data["profilePath"] as? String
        )
    }

    private static func intValue(from raw: Any?) -> Int? {
        if let value = raw as? Int { return value }
        if let value = raw as? NSNumber { return value.intValue }
        if let value = raw as? String { return Int(value) }
        return nil
    }
}
