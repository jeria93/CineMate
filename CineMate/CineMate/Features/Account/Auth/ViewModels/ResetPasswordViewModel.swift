//
//  ResetPasswordViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-24.
//

import Foundation

/// View model for ResetPasswordSheet.
/// Handles email input, loading state, and reset action.
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
    
    /// Send button state.
    var canSubmit: Bool { !isSending }
    
    /// Email helper text after submit.
    var emailHelperText: String? { AuthValidator.emailHelperText(email: email, hasTriedSubmit: hasTriedSubmit) }
    
    /// Production init.
    init(service: FirebaseAuthService, onResetSent: @escaping (String) -> Void) {
        self.service = service
        self.onResetSent = onResetSent
    }
    
    /// Preview init.
    init(previewEmail: String = "") {
        self.service = nil
        self.onResetSent = { _ in }
        self.email = previewEmail
    }
    
    /// Sends reset email when input is valid.
    /// Returns true on success.
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
    
    func clearError() {
        appError = nil
    }
}

// Preview helpers
extension ResetPasswordViewModel {
    func setPreviewSending(_ value: Bool) { self.isSending = value }
    func setPreviewError(_ error: AuthAppError?) { self.appError = error }
}
