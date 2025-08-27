//
//  AccountView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import SwiftUI

/// **AccountView+Previews**
/// Convenience, named previews for common Account states.
extension AccountView {
    /// Preview: user signed out.
    static var previewSignedOut: some View {
        AccountView(viewModel: PreviewFactory.accountSignedOut())
    }

    /// Preview: user signed in (shows short UID).
    static var previewSignedIn: some View {
        AccountView(viewModel: PreviewFactory.accountSignedIn())
    }

    /// Preview: error state (auth failure message).
    static var previewError: some View {
        AccountView(viewModel: PreviewFactory.accountError())
    }

    /// Preview: authenticating (inline loading UI).
    static var previewIsAuthenticating: some View {
        AccountView(viewModel: PreviewFactory.accountIsAuthenticating())
    }
}
