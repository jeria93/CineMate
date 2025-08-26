//
//  PreviewFactory+CreateAccount.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-20.
//

import SwiftUI

/// Preview factory for `CreateAccountView`.
/// Builds small, offline `CreateAccountViewModel` samples for common states
/// (empty, valid, invalid, loading, server error). No network calls.
@MainActor
extension PreviewFactory {

    /// Empty form — all fields blank, no validation shown.
    static func createEmpty() -> CreateAccountViewModel {
        CreateAccountViewModel(previewEmail: "")
    }

    /// Valid form — email/passwords OK and terms accepted; submit enabled.
    static func createFilledValid() -> CreateAccountViewModel {
        let createViewModel = CreateAccountViewModel(previewEmail: CreateAccountPreviewData.validEmail)
        createViewModel.password = CreateAccountPreviewData.strongPassword
        createViewModel.confirmPassword = CreateAccountPreviewData.strongPassword
        createViewModel.acceptedTerms = true
        return createViewModel
    }

    /// Passwords mismatch — shows field-level error for confirmation.
    static func createPasswordMismatch() -> CreateAccountViewModel {
        let createViewModel = CreateAccountViewModel(previewEmail: CreateAccountPreviewData.validEmail)
        createViewModel.password = CreateAccountPreviewData.strongPassword
        createViewModel.confirmPassword = CreateAccountPreviewData.weakPassword
        createViewModel.acceptedTerms = true
        return createViewModel
    }

    /// Invalid email — triggers email validation to fail.
    static func createInvalidEmail() -> CreateAccountViewModel {
        let createViewModel = CreateAccountViewModel(previewEmail: CreateAccountPreviewData.invalidEmail)
        createViewModel.password = CreateAccountPreviewData.strongPassword
        createViewModel.confirmPassword = CreateAccountPreviewData.strongPassword
        createViewModel.acceptedTerms = true
        return createViewModel
    }

    /// Loading state — spinner visible; inputs and submit disabled.
    static func createIsAuthenticating() -> CreateAccountViewModel {
        let createViewModel = CreateAccountViewModel(previewEmail: CreateAccountPreviewData.validEmail, previewIsAuthenticating: true)
        createViewModel.password = CreateAccountPreviewData.strongPassword
        createViewModel.confirmPassword = CreateAccountPreviewData.strongPassword
        createViewModel.acceptedTerms = true
        return createViewModel
    }

    /// Server error — sets `errorMessage` (e.g. “email already in use”).
    static func makeServerError() -> CreateAccountViewModel {
        let createViewModel = CreateAccountViewModel(
            previewEmail: CreateAccountPreviewData.validEmail,
            previewIsAuthenticating: false,
            previewErrorMessage: CreateAccountPreviewData.remoteErrorText
        )
        createViewModel.password = CreateAccountPreviewData.strongPassword
        createViewModel.confirmPassword = CreateAccountPreviewData.strongPassword
        createViewModel.acceptedTerms = true
        return createViewModel
    }

    /// Terms not accepted — shows helper text; simulates a failed submit.
    static func previewTermsNotAccepted() -> CreateAccountViewModel {
        let createViewModel = CreateAccountViewModel(previewEmail: CreateAccountPreviewData.validEmail)
        createViewModel.password = CreateAccountPreviewData.strongPassword
        createViewModel.confirmPassword = CreateAccountPreviewData.strongPassword
        createViewModel.acceptedTerms = false
        createViewModel.hasTriedSubmit = true
        return createViewModel
    }
}
