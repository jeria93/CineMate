//
//  FirestorePaths.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-09.
//

import Foundation
import FirebaseFirestore

/// Central place for building Firestore paths.
/// Keeps string literals out of call sites and ensures consistency.
enum FirestorePaths {

    /// `/users/{uid}/favorites` – movie favorites of a user.
    /// - Parameter uid: Firebase Auth user ID.
    /// - Returns: Collection reference for the user's movie favorites.
    static func userFavorites(uid: String) -> CollectionReference {
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("favorites")
    }

    /// `/users/{uid}/favorite_people` – people favorites of a user.
    /// - Parameter uid: Firebase Auth user ID.
    /// - Returns: Collection reference for the user's people favorites.
    static func userFavoritePeople(uid: String) -> CollectionReference {
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("favorite_people")
    }
}
