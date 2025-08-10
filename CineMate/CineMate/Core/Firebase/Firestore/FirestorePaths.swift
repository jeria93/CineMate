//
//  FirestorePaths.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-09.
//

import Foundation
import FirebaseFirestore

/// **Centralized Firestore path builder**
///
/// Provides static helper methods to build Firestore collection/document paths
/// in one place, avoiding magic strings and ensuring consistency.
///
/// ### Responsibilities
/// - Define Firestore collection/document paths for the app.
/// - Keep path logic in a single location for easier maintenance.
/// - Prevent typos or mismatches in collection/document names.
///
/// ### Usage
/// ```swift
/// let uid = try await authService.isLoggedIn()
/// let favoritesRef = FirestorePaths.userFavorites(uid: uid)
/// try await favoritesRef.addDocument(data: ["title": "Inception"])
/// ```
///
/// **Firestore structure:**
/// ```
/// users
///   └── {uid}
///         └── favorites
///               ├── {movieDoc1}
///               ├── {movieDoc2}
///               └── ...
/// ```
enum FirestorePaths {

    /// Returns a reference to the "favorites" collection for a specific user.
    ///
    /// - Parameter uid: The unique Firebase Auth user ID.
    /// - Returns: A `CollectionReference` pointing to `/users/{uid}/favorites`.
    static func userFavorites(uid: String) -> CollectionReference {
        Firestore.firestore()
            .collection("users")      // Root collection for all users
            .document(uid)            // Specific user's document
            .collection("favorites")  // Subcollection containing their favorite movies
    }
}
