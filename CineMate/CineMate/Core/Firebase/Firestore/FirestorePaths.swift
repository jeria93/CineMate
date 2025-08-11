//
//  FirestorePaths.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-09.
//

import Foundation
import FirebaseFirestore

/// # FirestorePaths
/// Centralizes Firestore path construction to avoid magic strings and keep paths consistent.
/// Keep path logic here so calling sites stay clean and testable.
enum FirestorePaths {

    /// `/users/{uid}/favorites` – the user's movie favorites collection.
    /// - Parameter uid: Firebase Auth user ID.
    /// - Returns: Collection reference for the user's movie favorites.
    static func userFavorites(uid: String) -> CollectionReference {
        Firestore.firestore()
            .collection("users")      // Root: all users
            .document(uid)            // User document
            .collection("favorites")  // Movie favorites subcollection
    }

    /// `/users/{uid}/favorite_people` – the user's people (actors/directors) favorites collection.
    /// - Parameter uid: Firebase Auth user ID.
    /// - Returns: Collection reference for the user's people favorites.
    static func userFavoritePeople(uid: String) -> CollectionReference {
        Firestore.firestore()
            .collection("users")             // Root: all users
            .document(uid)                   // User document
            .collection("favorite_people")   // People favorites subcollection
    }
}
