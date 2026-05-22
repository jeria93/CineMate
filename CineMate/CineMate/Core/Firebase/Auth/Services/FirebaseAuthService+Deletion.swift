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
/// Firestore cleanup runs locally for known user collections.
extension FirebaseAuthService {

    // MARK: - Public API

    enum AccountDeletionResult {
        case success
        case requiresRecentLogin
    }

    /// Deletes current user data and account.
    /// Returns requiresRecentLogin when Firebase needs fresh login.
    func deleteCurrentAccountWithDataCleanup() async throws -> AccountDeletionResult {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        guard let user = Auth.auth().currentUser else { throw AuthServiceError.noCurrentUser }
        let uid = user.uid

        try await deleteUserData(uid: uid)

        do {
            try await user.delete()
        } catch {
            guard isRecentLoginRequired(error) else { throw error }

            // Sign out so the app can ask for login again.
            try? signOut()
            return .requiresRecentLogin
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

    // MARK: - Local cleanup

    /// Deletes known Firestore data under users uid.
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
