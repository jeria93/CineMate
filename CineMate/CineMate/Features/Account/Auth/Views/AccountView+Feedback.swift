//
//  AccountView+Feedback.swift
//  CineMate
//
//  Created by OpenAI Codex on 2026-06-03.
//

import SwiftUI

/// Feedback helpers kept outside the main view file.
/// They map async account results to local section feedback without changing view state ownership.
extension AccountView {
    /// Maps change email results to short user-facing feedback.
    func handleChangeEmailResult(_ result: AuthViewModel.ChangeEmailResult) {
        switch result {
        case .verificationSent(let email):
            changeEmailFeedback = .success("Verification link sent to \(email).")
            authViewModel.errorMessage = nil
        case .unavailable:
            changeEmailFeedback = .error("Email change is only available for email sign in.")
            authViewModel.errorMessage = nil
        case .cooldown(let seconds):
            changeEmailFeedback = .error("Wait \(seconds) seconds before sending another link.")
            authViewModel.errorMessage = nil
        case .needsRecentLogin:
            changeEmailFeedback = .error("Please sign in again to change your email.")
            authViewModel.errorMessage = nil
        case .failure(let message):
            changeEmailFeedback = .error(message)
            authViewModel.errorMessage = nil
        }
    }
    
    /// Maps terms acceptance results to short user-facing feedback.
    func handleAcceptTermsResult(_ result: AuthViewModel.AcceptTermsResult) {
        switch result {
        case .saved:
            legalFeedback = .success("Accepted terms version \(TermsContent.currentVersion).")
            authViewModel.errorMessage = nil
        case .unavailable:
            legalFeedback = .error("Terms acceptance not available for this account.")
            authViewModel.errorMessage = nil
        case .failure(let message):
            legalFeedback = .error(message)
            authViewModel.errorMessage = nil
        }
    }
}
