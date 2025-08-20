//
//  LoginView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-18.
//

import SwiftUI

/// SwiftUI previews for **LoginView**.
/// Uses `PreviewFactory` builders to showcase common UI states.
extension LoginView {

    /// Empty form (idle)
    static var previewEmpty: some View {
        LoginView(viewModel: PreviewFactory.loginEmpty())
    }

    /// Filled form (valid inputs)
    static var previewFilled: some View {
        LoginView(viewModel: PreviewFactory.loginFilledValid())
    }

    /// Error banner visible
    static var previewError: some View {
        LoginView(viewModel: PreviewFactory.loginError())
    }

    /// Busy/Loading overlay
    static var previewIsAuthenticating: some View {
        LoginView(viewModel: PreviewFactory.loginIsAuthenticating())
    }
}
