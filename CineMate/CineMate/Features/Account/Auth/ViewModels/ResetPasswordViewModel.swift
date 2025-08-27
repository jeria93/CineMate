//
//  ResetPasswordViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-24.
//

import Foundation

/// ViewModel for the Reset Password sheet.
/// Owns form/UI state, validates, and calls the auth service.
/// Runs on main actor because it mutates observable UI state.
@MainActor
final class ResetPasswordViewModel: ObservableObject {

    // Form
    @Published var email: String = ""

    // UI state (VM-only mutation)
    @Published private(set) var isSending = false
    @Published private(set) var appError: AuthAppError?
    @Published var hasTriedSubmit = false

    // Dependencies
    private let service: FirebaseAuthService?       // nil in previews
    private let onResetSent: (String) -> Void       // called on success

    // Derived UI
    var isEmailValid: Bool { AuthValidator.isValidEmail(email) }

    /// Button enablement; validation happens on submit so we don't nag early.
    var canSubmit: Bool { !isSending }

    var showClearEmailIcon: Bool { !email.isEmpty && !isSending }

    /// Shown only after first submit if email is invalid.
    var emailHelperText: String? {
        hasTriedSubmit && !isEmailValid ? "Enter a valid email address" : nil
    }

    /// Live init.
    init(service: FirebaseAuthService, onResetSent: @escaping (String) -> Void) {
        self.service = service
        self.onResetSent = onResetSent
    }

    /// Preview init (no network).
    init(previewEmail: String = "") {
        self.service = nil
        self.onResetSent = { _ in }
        self.email = previewEmail
    }

    /// Sanitize on change and clear previous error.
    func updateEmail(_ newValue: String) {
        email = AuthValidator.sanitizedEmail(from: newValue)
        appError = nil
    }

    /// Send reset email if input is valid.
    /// - Returns: `true` on success; otherwise `false`.
    @discardableResult
    func sendPasswordReset() async -> Bool {
        hasTriedSubmit = true
        email = AuthValidator.sanitizedEmail(from: email)
        guard isEmailValid, let service else { return false }

        isSending = true
        appError = nil
        defer { isSending = false }

        do {
            try await service.sendPasswordReset(email: email)
            onResetSent(email)
            return true
        } catch {
            appError = AuthAppError.mapToAppError(error)
            return false
        }
    }
}

// Preview-only helpers (don’t call in production)
extension ResetPasswordViewModel {
    func setPreviewSending(_ value: Bool) { self.isSending = value }
    func setPreviewError(_ error: AuthAppError?) { self.appError = error }
    func clearError() { self.appError = nil }
}
