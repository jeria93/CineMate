//
//  AccountView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import SwiftUI

/// Preview states for `AccountView`.
extension AccountView {
    /// Signed out state.
    static var previewSignedOut: some View {
        AccountView(viewModel: PreviewFactory.accountSignedOut()).withPreviewEnvironment()
    }

    /// Signed in state.
    static var previewSignedIn: some View {
        AccountView(viewModel: PreviewFactory.accountSignedIn()).withPreviewEnvironment()
    }

    /// Error state.
    static var previewError: some View {
        AccountView(viewModel: PreviewFactory.accountError()).withPreviewEnvironment()
    }

    /// Loading state.
    static var previewIsAuthenticating: some View {
        AccountView(viewModel: PreviewFactory.accountIsAuthenticating()).withPreviewEnvironment()
    }
}
