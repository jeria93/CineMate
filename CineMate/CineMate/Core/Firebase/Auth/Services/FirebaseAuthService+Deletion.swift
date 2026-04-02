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
/// Handles auth account delete and recent login cases.
/// User Firestore cleanup should be handled by a backend Cloud Function on user delete.
/// Until backend deploy is active, this file keeps a local best-effort cleanup fallback.
extension FirebaseAuthService {

    // MARK: - Public API

    enum AccountDeletionResult {
        case success
        case requiresRecentLogin
    }

    /// Deletes current user data and account.
    /// It deletes the Firebase user.
    /// Firestore cleanup should be performed server-side by backend automation.
    /// A temporary local fallback cleanup runs after successful account deletion.
    /// Returns requiresRecentLogin when Firebase needs fresh login.
    func deleteCurrentAccountWithDataCleanup() async throws -> AccountDeletionResult {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        guard let user = Auth.auth().currentUser else { throw AuthServiceError.noCurrentUser }
        let uid = user.uid

        do {
            try await user.delete()
        } catch {
            guard isRecentLoginRequired(error) else { throw error }

            // Sign out so the app can ask for login again.
            // No Firestore data has been deleted at this point.
            try? signOut()
            return .requiresRecentLogin
        }

        // Temporary fallback: local cleanup after successful auth deletion.
        // This keeps data hygiene while backend function deployment is pending.
        // If this fails, we still return success because auth account is gone.
        do {
            try await deleteUserData(uid: uid)
        } catch {
            logDeletion("local fallback cleanup failed for uid=\(uid): \(error.localizedDescription)")
        }

        // SDK may already clear session after delete; treat local sign-out as best-effort.
        try? signOut()
        return .success
    }

    /// Returns true when Firebase asks for recent login.
    func isRecentLoginRequired(_ error: Error) -> Bool {
        let ns = error as NSError
        return AuthErrorCode(rawValue: ns.code) == .requiresRecentLogin
    }

    // MARK: - Temporary local cleanup fallback

    /// Deletes known Firestore data under users uid.
    /// This is a temporary fallback while backend cleanup is not yet deployed.
    fileprivate func deleteUserData(uid: String) async throws {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }

        // Clear known subcollections in small batches, then remove the user doc.
        try await deleteAllDocuments(in: FirestorePaths.userFavorites(uid: uid))
        try await deleteAllDocuments(in: FirestorePaths.userFavoritePeople(uid: uid))
        try await FirestorePaths.userDoc(uid: uid).delete()
    }

    /// Deletes all docs in a collection in small batches.
    /// Keeps memory stable and stays under Firestore batch limits.
    private func deleteAllDocuments(in collection: CollectionReference, batchSize: Int = 200) async throws {
        var lastSnapshot: QueryDocumentSnapshot?

        while true {
            var query: Query = collection.limit(to: batchSize)
            if let last = lastSnapshot {
                query = query.start(afterDocument: last)
            }

            let snap = try await query.getDocuments()
            guard !snap.documents.isEmpty else { break }

            let batch = collection.firestore.batch()
            for doc in snap.documents {
                batch.deleteDocument(doc.reference)
            }
            try await batch.commit()

            lastSnapshot = snap.documents.last
            try Task.checkCancellation()
        }
    }

    private func logDeletion(_ message: String) {
#if DEBUG
        print("[App][Auth][Delete] \(message)")
#endif
    }
}
