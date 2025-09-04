//
//  FirestorePaths.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-09.
//

import FirebaseFirestore

/// FirestorePaths
/// --------------
/// A small helper to build Firestore references in one place.
/// Why?
/// - Avoid hard-coded strings like "users" scattered in the codebase.
/// - Keep paths consistent and easy to change later.
/// - Return **references only** (no reads/writes here).
enum FirestorePaths {

    /// The shared Firestore instance.
    private static var db: Firestore { Firestore.firestore() }

    /// `/users` collection.
    static func users() -> CollectionReference {
        db.collection("users")
    }

    /// `/users/{uid}` document.
    /// - Parameter uid: The Firebase Auth user ID.
    static func userDoc(uid: String) -> DocumentReference {
        users().document(uid)
    }

    /// `/users/{uid}/favorites` collection.
    /// - Parameter uid: The Firebase Auth user ID.
    static func userFavorites(uid: String) -> CollectionReference {
        userDoc(uid: uid).collection("favorites")
    }

    /// `/users/{uid}/favorite_people` collection.
    /// - Parameter uid: The Firebase Auth user ID.
    static func userFavoritePeople(uid: String) -> CollectionReference {
        userDoc(uid: uid).collection("favorite_people")
    }
}
