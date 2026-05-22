//
//  PreviewFactory+CreateAccount.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-20.
//

import SwiftUI

/// Preview factory for `CreateAccountView`.
/// Builds small local `CreateAccountViewModel` samples for common states.
@MainActor
extension PreviewFactory {

    /// Empty form with no validation messages.
    static func createEmpty() -> CreateAccountViewModel {
        CreateAccountViewModel(previewEmail: "")
    }

    /// Valid form with accepted terms and privacy policy.
    static func createFilledValid() -> CreateAccountViewModel {
        let createViewModel = CreateAccountViewModel(previewEmail: CreateAccountPreviewData.validEmail)
        createViewModel.password = CreateAccountPreviewData.strongPassword
        createViewModel.confirmPassword = CreateAccountPreviewData.strongPassword
        createViewModel.acceptedTerms = true
        createViewModel.acceptedPrivacyPolicy = true
        return createViewModel
    }

    /// Password mismatch preview.
    static func createPasswordMismatch() -> CreateAccountViewModel {
        let createViewModel = CreateAccountViewModel(previewEmail: CreateAccountPreviewData.validEmail)
        createViewModel.password = CreateAccountPreviewData.strongPassword
        createViewModel.confirmPassword = CreateAccountPreviewData.weakPassword
        createViewModel.acceptedTerms = true
        createViewModel.acceptedPrivacyPolicy = true
        return createViewModel
    }

    /// Invalid email preview.
    static func createInvalidEmail() -> CreateAccountViewModel {
        let createViewModel = CreateAccountViewModel(previewEmail: CreateAccountPreviewData.invalidEmail)
        createViewModel.password = CreateAccountPreviewData.strongPassword
        createViewModel.confirmPassword = CreateAccountPreviewData.strongPassword
        createViewModel.acceptedTerms = true
        createViewModel.acceptedPrivacyPolicy = true
        return createViewModel
    }

    /// Loading state with disabled inputs.
    static func createIsAuthenticating() -> CreateAccountViewModel {
        let createViewModel = CreateAccountViewModel(previewEmail: CreateAccountPreviewData.validEmail, previewIsAuthenticating: true)
        createViewModel.password = CreateAccountPreviewData.strongPassword
        createViewModel.confirmPassword = CreateAccountPreviewData.strongPassword
        createViewModel.acceptedTerms = true
        createViewModel.acceptedPrivacyPolicy = true
        return createViewModel
    }

    /// Server error preview.
    static func makeServerError() -> CreateAccountViewModel {
        let createViewModel = CreateAccountViewModel(
            previewEmail: CreateAccountPreviewData.validEmail,
            previewIsAuthenticating: false,
            previewErrorMessage: CreateAccountPreviewData.remoteErrorText
        )
        createViewModel.password = CreateAccountPreviewData.strongPassword
        createViewModel.confirmPassword = CreateAccountPreviewData.strongPassword
        createViewModel.acceptedTerms = true
        createViewModel.acceptedPrivacyPolicy = true
        return createViewModel
    }

    /// Terms not accepted preview.
    static func previewTermsNotAccepted() -> CreateAccountViewModel {
        let createViewModel = CreateAccountViewModel(previewEmail: CreateAccountPreviewData.validEmail)
        createViewModel.password = CreateAccountPreviewData.strongPassword
        createViewModel.confirmPassword = CreateAccountPreviewData.strongPassword
        createViewModel.acceptedTerms = false
        createViewModel.acceptedPrivacyPolicy = true
        createViewModel.hasTriedSubmit = true
        return createViewModel
    }
}
