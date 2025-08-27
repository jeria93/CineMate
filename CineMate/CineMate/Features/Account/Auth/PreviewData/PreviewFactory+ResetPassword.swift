//
//  PreviewFactory+ResetPassword.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-24.
//

import SwiftUI

/// Preview builders for the Reset Password screen.
/// Each function returns a **preconfigured ViewModel** with no network dependency.
/// This keeps preview declarations in views extremely small.
@MainActor
extension PreviewFactory {
    /// Empty form; idle state.
    static func resetEmptyVM() -> ResetPasswordViewModel {
        ResetPasswordViewModel(previewEmail: "")
    }

    /// Filled form with a valid email; idle state.
    static func resetFilledVM() -> ResetPasswordViewModel {
        ResetPasswordViewModel(previewEmail: ResetPasswordPreviewData.validEmail)
    }

    /// Busy/sending state (spinner visible, inputs disabled).
    static func resetSendingVM() -> ResetPasswordViewModel {
        let vm = ResetPasswordViewModel(previewEmail: ResetPasswordPreviewData.validEmail)
        vm.setPreviewSending(true)
        return vm
    }

    /// Invalid email entered; helper text should be visible after first submit.
    static func resetInvalidEmailVM() -> ResetPasswordViewModel {
        ResetPasswordViewModel(previewEmail: ResetPasswordPreviewData.invalidEmail)
    }

    /// Server/network error surfaced by the ViewModel.
    static func resetServerErrorVM() -> ResetPasswordViewModel {
        let vm = ResetPasswordViewModel(previewEmail: ResetPasswordPreviewData.validEmail)
        vm.setPreviewError(.unknown(ResetPasswordPreviewData.networkErrorText))
        return vm
    }
}
