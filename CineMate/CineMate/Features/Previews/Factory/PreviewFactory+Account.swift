//
//  PreviewFactory+Account.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

/// **PreviewFactory+Account**
/// Ready-made `AuthViewModel` states for Account previews.
/// Purely local scaffolding; never touches Firebase.
@MainActor
extension PreviewFactory {

    /// Signed-out state (no user logged in).
    static func accountSignedOut() -> AuthViewModel {
        AuthViewModel(simulatedUID: nil)
    }

    /// Signed-in state with a demo UID.
    static func accountSignedIn() -> AuthViewModel {
        AuthViewModel(simulatedUID: AuthPreviewData.demoUID)
    }

    /// Error state (shows an auth error banner).
    static func accountError() -> AuthViewModel {
        AuthViewModel(simulatedUID: nil, previewError: AuthPreviewData.errorText)
    }

    /// Busy/loading state (spinner visible, inputs disabled).
    static func accountIsAuthenticating() -> AuthViewModel {
        AuthViewModel(simulatedUID: nil, IsAuthenticating: true)
    }
}
