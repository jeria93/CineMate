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

    // MARK: - Root

    /// `/users` collection.
    static func users(in db: Firestore) -> CollectionReference {
        db.collection("users")
    }

    /// `/users` collection (shared Firestore).
    static func users() -> CollectionReference {
        users(in: Firestore.firestore())
    }

    // MARK: - User

    /// `/users/{uid}` document.
    /// - Parameter uid: The Firebase Auth user ID.
    static func userDoc(uid: String, in db: Firestore) -> DocumentReference {
        users(in: db).document(uid)
    }

    /// `/users/{uid}` document (shared Firestore).
    /// - Parameter uid: The Firebase Auth user ID.
    static func userDoc(uid: String) -> DocumentReference {
        userDoc(uid: uid, in: Firestore.firestore())
    }

    // MARK: - Favorites

    /// `/users/{uid}/favorites` collection.
    /// - Parameter uid: The Firebase Auth user ID.
    static func userFavorites(uid: String, in db: Firestore) -> CollectionReference {
        userDoc(uid: uid, in: db).collection("favorites")
    }

    /// `/users/{uid}/favorites` collection (shared Firestore).
    /// - Parameter uid: The Firebase Auth user ID.
    static func userFavorites(uid: String) -> CollectionReference {
        userFavorites(uid: uid, in: Firestore.firestore())
    }

    /// `/users/{uid}/favorite_people` collection.
    /// - Parameter uid: The Firebase Auth user ID.
    static func userFavoritePeople(uid: String, in db: Firestore) -> CollectionReference {
        userDoc(uid: uid, in: db).collection("favorite_people")
    }

    /// `/users/{uid}/favorite_people` collection (shared Firestore).
    /// - Parameter uid: The Firebase Auth user ID.
    static func userFavoritePeople(uid: String) -> CollectionReference {
        userFavoritePeople(uid: uid, in: Firestore.firestore())
    }
}
