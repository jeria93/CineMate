//
//  PreviewFactory+CreateAccount.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-20.
//

import SwiftUI

@MainActor
extension PreviewFactory {

    static func createEmpty() -> CreateAccountViewModel {
        CreateAccountViewModel(previewEmail: "")
    }

    static func createFilledValid() -> CreateAccountViewModel {
        let createViewModel = CreateAccountViewModel(previewEmail: CreateAccountPreviewData.validEmail)
        createViewModel.password = CreateAccountPreviewData.strongPassword
        createViewModel.confirmPassword = CreateAccountPreviewData.strongPassword
        createViewModel.acceptedTerms = true
        return createViewModel
    }

    static func createPasswordMismatch() -> CreateAccountViewModel {
        let createViewModel = CreateAccountViewModel(previewEmail: CreateAccountPreviewData.validEmail)
        createViewModel.password = CreateAccountPreviewData.strongPassword
        createViewModel.confirmPassword = CreateAccountPreviewData.strongPassword
        createViewModel.acceptedTerms = false
        return createViewModel
    }

    static func createInvalidEmail() -> CreateAccountViewModel {
        let createViewModel = CreateAccountViewModel(previewEmail: CreateAccountPreviewData.invalidEmail)
        createViewModel.password = CreateAccountPreviewData.strongPassword
        createViewModel.confirmPassword = CreateAccountPreviewData.strongPassword
        createViewModel.acceptedTerms = false
        return createViewModel
    }

    static func createIsAuthenticating() -> CreateAccountViewModel {
        let createViewModel = CreateAccountViewModel(previewEmail: CreateAccountPreviewData.validEmail, previewIsAuthenticating: true)
        createViewModel.password = CreateAccountPreviewData.strongPassword
        createViewModel.confirmPassword = CreateAccountPreviewData.strongPassword
        createViewModel.acceptedTerms = true
        return createViewModel
    }

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
}
