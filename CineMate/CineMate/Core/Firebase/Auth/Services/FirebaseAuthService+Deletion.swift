//
//  FirebaseAuthService+Deletion.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-09-03.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Delete helpers for FirebaseAuthService.
/// Handles Firestore cleanup, auth account delete, and recent login cases.
extension FirebaseAuthService {

    // MARK: - Public API

    enum AccountDeletionResult {
        case success
        case requiresRecentLogin
    }

    /// Deletes current user data and account.
    /// First it deletes known Firestore data.
    /// Then it deletes the Firebase user and signs out.
    /// Returns requiresRecentLogin when Firebase needs fresh login.
    func deleteCurrentAccountWithDataCleanup() async throws -> AccountDeletionResult {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        guard let user = Auth.auth().currentUser else { throw AuthServiceError.noCurrentUser }

        try await deleteUserData(uid: user.uid)

        do {
            try await user.delete()
        } catch {
            guard isRecentLoginRequired(error) else { throw error }

            // Anonymous users cannot reauthenticate in a useful way.
            if user.isAnonymous {
                try? signOut()
                return .success
            }

            // Sign out so the app can ask for login again.
            try? signOut()
            return .requiresRecentLogin
        }

        try signOut()
        return .success
    }

    /// Deletes known Firestore data under users uid.
    /// Call this before deleting the auth user.
    func deleteUserData(uid: String) async throws {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }

        // Clear known subcollections in small batches, then remove the user doc.
        try await deleteAllDocuments(in: FirestorePaths.userFavorites(uid: uid))
        try await deleteAllDocuments(in: FirestorePaths.userFavoritePeople(uid: uid))
        try await FirestorePaths.userDoc(uid: uid).delete()
    }

    /// Returns true when Firebase asks for recent login.
    func isRecentLoginRequired(_ error: Error) -> Bool {
        let ns = error as NSError
        return AuthErrorCode(rawValue: ns.code) == .requiresRecentLogin
    }

    // MARK: - Private

    /// Deletes all docs in a collection in small batches.
    /// This keeps memory stable and stays under batch limits.
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
