//
//  CreateAccountView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-20.
//

import SwiftUI

/// SwiftUI previews for **CreateAccountView**.
/// Uses `PreviewFactory` to inject deterministic, offline view-models.
extension CreateAccountView {

    /// Empty form (idle).
    static var previewEmpty: some View {
        CreateAccountView(createViewModel: PreviewFactory.createEmpty())
            .withPreviewNavigation()
    }

    /// Filled with valid data; all validations pass.
    static var previewFilledValid: some View {
        CreateAccountView(createViewModel: PreviewFactory.createFilledValid())
            .withPreviewNavigation()
    }

    /// Passwords don't match / or terms not accepted (failing validation).
    static var previewPasswordMismatch: some View {
        CreateAccountView(createViewModel: PreviewFactory.createPasswordMismatch())
            .withPreviewNavigation()
    }

    /// Invalid email format.
    static var previewInvalidEmail: some View {
        CreateAccountView(createViewModel: PreviewFactory.createInvalidEmail())
            .withPreviewNavigation()
    }

    /// Busy state (spinner visible, buttons disabled).
    static var previewIsAuthenticating: some View {
        CreateAccountView(createViewModel: PreviewFactory.createIsAuthenticating())
            .withPreviewNavigation()
    }

    /// Backend/server error returned (e.g. email already in use).
    static var previewServerError: some View {
        CreateAccountView(createViewModel: PreviewFactory.makeServerError())
            .withPreviewNavigation()
    }
}
