//
//  PreviewFactory+Login.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-18.
//

import Foundation

/// **PreviewFactory+Login**
/// Ready-made `LoginViewModel` states for SwiftUI previews.
/// Purely local; never touches Firebase or the network.
@MainActor
extension PreviewFactory {

    /// Empty form (all fields blank)
    static func loginEmpty() -> LoginViewModel {
        LoginViewModel(previewEmail: "")
    }

    /// Filled form with valid email and password
    static func loginFilledValid() -> LoginViewModel {
        let loginViewModel = LoginViewModel(previewEmail: LoginPreviewData.validEmail)
        loginViewModel.password = LoginPreviewData.password
        return loginViewModel
    }

    /// Error state (shows an inline error message)
    static func loginError() -> LoginViewModel {
        LoginViewModel(
            previewEmail: LoginPreviewData.validEmail,
            previewIsAuthenticating: false,
            previewError: LoginPreviewData.errorText
        )
    }

    /// IsAuthenticating state (spinner visible, buttons disabled)
    static func loginIsAuthenticating() -> LoginViewModel {
        let loginViewModel = LoginViewModel(previewEmail: LoginPreviewData.validEmail, previewIsAuthenticating: true)
        loginViewModel.password = LoginPreviewData.password
        return loginViewModel
    }
}
