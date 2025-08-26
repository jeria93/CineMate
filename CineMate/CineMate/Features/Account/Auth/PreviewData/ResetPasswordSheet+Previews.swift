//
//  ResetPasswordSheet+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-24.
//

import SwiftUI

/// Xcode Previews for `ResetPasswordSheet`.
/// Uses `PreviewFactory` to keep each case one-liners.
extension ResetPasswordSheet {
    /// Empty form; nothing typed.
    static var previewEmpty: some View {
        ResetPasswordSheet(viewModel: PreviewFactory.resetEmptyVM())
            .withPreviewToasts()
    }

    /// Form prefilled with a valid email; ready to submit.
    static var previewFilled: some View {
        ResetPasswordSheet(viewModel: PreviewFactory.resetFilledVM())
            .withPreviewToasts()
    }

    /// Simulates an in-flight send operation.
    static var previewSending: some View {
        ResetPasswordSheet(viewModel: PreviewFactory.resetSendingVM())
            .withPreviewToasts()
    }

    /// Shows validation message for an invalid email after submit.
    static var previewInvalidEmail: some View {
        ResetPasswordSheet(viewModel: PreviewFactory.resetInvalidEmailVM())
            .withPreviewToasts()
    }

    /// Displays a server/network error message from the ViewModel.
    static var previewServerError: some View {
        ResetPasswordSheet(viewModel: PreviewFactory.resetServerErrorVM())
            .withPreviewToasts()
    }
}
