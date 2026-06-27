//
//  AccountLegalSectionModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-06-27.
//

/// Groups legal section display state while actions remain callbacks on the view.
struct AccountLegalSectionModel {
    let status: AccountLegalStatus
    let acceptedTermsVersionText: String?
    let acceptedPrivacyVersionText: String?
    let lastCheckedText: String?
    let shouldShowAcceptLatest: Bool
    let isAuthenticating: Bool
    let isAcceptingLatestTerms: Bool
    let feedback: AccountInlineFeedback?
}
