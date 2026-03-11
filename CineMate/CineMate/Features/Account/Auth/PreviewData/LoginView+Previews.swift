//
//  LoginView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-18.
//

import SwiftUI

/// SwiftUI previews for **LoginView**.
/// Uses `PreviewFactory` to provide mock view-models.
/// Helper:
/// - `.withPreviewToasts()` injects a fake `ToastCenter`.
extension LoginView {

    /// Empty form (idle).
    static var previewEmpty: some View {
        LoginView(viewModel: PreviewFactory.loginEmpty())
            .withPreviewToasts()
    }

    /// Filled form (valid inputs).
    static var previewFilled: some View {
        LoginView(viewModel: PreviewFactory.loginFilledValid())
            .withPreviewToasts()
    }

    /// Error banner visible.
    static var previewError: some View {
        LoginView(viewModel: PreviewFactory.loginError())
            .withPreviewToasts()
    }

    /// Busy/loading overlay.
    static var previewIsAuthenticating: some View {
        LoginView(viewModel: PreviewFactory.loginIsAuthenticating())
            .withPreviewToasts()
    }
}
