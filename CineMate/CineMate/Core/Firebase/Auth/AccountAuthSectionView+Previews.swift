//
//  AccountAuthSectionView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-17.
//

import SwiftUI

/// SwiftUI previews for **AccountAuthSectionView**.
/// Uses the view model’s *preview initializer* so no Firebase SDK is touched in canvas.
/// Provides four deterministic states (signed out/in, error, busy) for quick visual checks.
extension AccountAuthSectionView {

    /// Signed-out state.
    /// - Injects a VM with `nil` UID to render the “Signed out / Preview mode” UI.
    static var previewSignedOut: some View {
        AccountAuthSectionView(viewModel: .init(previewUID: nil))
    }

    /// Signed-in state.
    /// - Injects a VM with a demo UID to render the “Signed in as …” UI.
    static var previewSignedIn: some View {
        AccountAuthSectionView(viewModel: .init(previewUID: AuthPreviewData.demoUID))
    }

    /// Error state.
    /// - Injects a VM with a static error message to show the red error text.
    static var previewError: some View {
        AccountAuthSectionView(viewModel: .init(previewError: AuthPreviewData.errorText))
    }

    /// Busy/loading state.
    /// - Injects a VM flagged as busy to show the spinner and disable buttons.
    static var previewBusy: some View {
        AccountAuthSectionView(viewModel: .init(previewBusy: true))
    }
}
