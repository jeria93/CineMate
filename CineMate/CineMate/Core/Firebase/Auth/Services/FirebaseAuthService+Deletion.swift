//
//  FirebaseAuthService+Deletion.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-09-03.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Deletion helpers for `FirebaseAuthService`.
/// ------------------------------------------------
/// What this extension does:
/// - Deletes a user's **Firestore subtree** under `/users/{uid}`
/// - Deletes the **Firebase Auth account**
/// - Handles the **"requires recent login"** case (with a tolerant variant for anonymous users)
///
/// Requirements:
/// - Firestore security rules must allow the signed-in user to read/write/delete
///   their own `/users/{uid}` document and everything under it (see README).
extension FirebaseAuthService {

    // MARK: - Public API

    /// Delete all Firestore data under `/users/{uid}` for the given user.
    ///
    /// Call this **before** deleting the Firebase Auth account.
    ///
    /// Notes:
    /// - This removes known subcollections (e.g., `favorites`, `favorite_people`)
    ///   and then deletes the user document itself.
    /// - If you add new subcollections in the future, include them here.
    ///
    /// - Throws: `PreviewAuthError` in previews, or Firestore errors.
    func deleteUserData(uid: String) async throws {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }

        // Clear known subcollections in small batches, then remove the user doc.
        try await deleteAllDocuments(in: FirestorePaths.userFavorites(uid: uid))
        try await deleteAllDocuments(in: FirestorePaths.userFavoritePeople(uid: uid))
        try await FirestorePaths.userDoc(uid: uid).delete()
    }

    /// Delete the **currently signed-in** Firebase Auth account.
    ///
    /// - Throws: `PreviewAuthError` in previews, `AuthServiceError.noCurrentUser`
    ///           when no user is signed in, or Firebase Auth errors.
    func deleteAccount() async throws {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        guard let user = Auth.auth().currentUser else { throw AuthServiceError.noCurrentUser }
        try await user.delete()
    }

    /// Delete the **currently signed-in** Firebase Auth account, but tolerate
    /// the "requires recent login" error for **anonymous** users.
    ///
    /// Why:
    /// - Anonymous sessions cannot be reauthenticated with a password, so we treat
    ///   `AuthErrorCode.requiresRecentLogin` as a no-op success in that case.
    ///
    /// - Throws: `PreviewAuthError` in previews, `AuthServiceError.noCurrentUser`
    ///           when no user is signed in, or rethrows other Firebase Auth errors.
    func deleteAccountTolerantForAnonymous() async throws {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        guard let user = Auth.auth().currentUser else { throw AuthServiceError.noCurrentUser }
        do {
            try await user.delete()
        } catch {
            // If the user is anonymous and Firebase asks for a "recent login",
            // there's nothing meaningful to reauthenticate with—treat as OK.
            if user.isAnonymous && isRecentLoginRequired(error) {
                return
            }
            throw error
        }
    }

    /// Returns `true` when the error is `.requiresRecentLogin`.
    func isRecentLoginRequired(_ error: Error) -> Bool {
        let ns = error as NSError
        return AuthErrorCode(rawValue: ns.code) == .requiresRecentLogin
    }

    // MARK: - Private

    /// Delete **all** documents in a collection using small batches (paging).
    ///
    /// Why batches:
    /// - Avoids hitting Firebase limits (max 500 writes per batch).
    /// - Keeps memory and network usage steady.
    ///
    /// - Parameters:
    ///   - collection: The collection to clear (e.g., `/users/{uid}/favorites`).
    ///   - batchSize: Number of docs per page (≤ 500). Default is 200.
    ///
    /// - Throws: Firestore errors for query/commit failures or task cancellation.
    fileprivate func deleteAllDocuments(in collection: CollectionReference, batchSize: Int = 200) async throws {
        // Remember the last document of each page (for start-after pagination).
        var lastSnapshot: QueryDocumentSnapshot?

        while true {
            // Fetch one page.
            var query: Query = collection.limit(to: batchSize)
            if let last = lastSnapshot {
                query = query.start(afterDocument: last)
            }

            let snap = try await query.getDocuments()
            guard !snap.documents.isEmpty else { break }

            // Delete that page in a single batch.
            let batch = collection.firestore.batch()
            for doc in snap.documents {
                batch.deleteDocument(doc.reference)
            }
            try await batch.commit()

            // Move the window forward.
            lastSnapshot = snap.documents.last

            // Cooperatively exit if the surrounding Task was cancelled.
            try Task.checkCancellation()
        }
    }
}
