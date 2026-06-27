//
//  AccountSecuritySectionModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-06-27.
//

/// Groups security section display state and derives status from available account actions.
struct AccountSecuritySectionModel {
    let currentEmail: String?
    let canChangeEmail: Bool
    let canSendPasswordReset: Bool
    let isAuthenticating: Bool
    let isSendingPasswordReset: Bool
    let changeEmailFeedback: AccountInlineFeedback?
    let passwordResetFeedback: AccountInlineFeedback?

    var status: AccountSecurityStatus {
        AccountSecurityStatus(
            canChangeEmail: canChangeEmail,
            canSendPasswordReset: canSendPasswordReset
        )
    }
}
