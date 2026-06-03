//
//  AccountView+Feedback.swift
//  CineMate
//
//  Created by OpenAI Codex on 2026-06-03.
//

import SwiftUI

/// Feedback helpers kept outside the main view file.
/// They map async account results to short toast messages without changing view state ownership.
extension AccountView {
    /// Maps change email results to short user-facing feedback.
    func handleChangeEmailResult(_ result: AuthViewModel.ChangeEmailResult) {
        switch result {
        case .verificationSent(let email):
            toastCenter.show("Verification link sent to \(email).")
        case .unavailable:
            toastCenter.show("Email change is only available for email sign in.")
        case .cooldown(let seconds):
            toastCenter.show("Wait \(seconds) seconds before sending another link.")
        case .needsRecentLogin:
            toastCenter.show("Please sign in again to change your email.")
        case .failure(let message):
            toastCenter.show(message)
        }
    }
    
    /// Maps terms acceptance results to short user-facing feedback.
    func handleAcceptTermsResult(_ result: AuthViewModel.AcceptTermsResult) {
        switch result {
        case .saved:
            toastCenter.show("Accepted terms version \(TermsContent.currentVersion).")
        case .unavailable:
            toastCenter.show("Terms acceptance not available for this account.")
        case .failure(let message):
            toastCenter.show(message)
        }
    }
}
