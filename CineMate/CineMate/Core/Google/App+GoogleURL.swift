//
//  App+GoogleURL.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-29.
//

import SwiftUI
import GoogleSignIn

/// Handle the Google Sign-In redirect URL.
/// Call on your root view so the SDK can finish the OAuth flow.
///
/// Usage:
/// ```swift
/// WindowGroup { RootView().handleGoogleSignInURL() }
/// ```
extension View {
    /// Forwards incoming URLs to GoogleSignIn.
    func handleGoogleSignInURL() -> some View {
        onOpenURL { url in
            _ = GIDSignIn.sharedInstance.handle(url)
        }
    }
}
