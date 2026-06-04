//
//  AccountSecurityStatus.swift
//  CineMate
//
//  Created by OpenAI Codex on 2026-06-03.
//

import SwiftUI

/// Maps available security actions into concise copy, icon, and tint for the account UI.
struct AccountSecurityStatus {
    let title: String
    let detail: String
    let iconSystemName: String
    let tint: Color
    
    init(canChangeEmail: Bool, canSendPasswordReset: Bool) {
        if canChangeEmail && canSendPasswordReset {
            title = "Email account"
            detail = "Email changes and password reset links are available for this account."
            iconSystemName = "checkmark.shield.fill"
            tint = Color.appPositive
        } else {
            title = "Limited controls"
            detail = "Some security actions are only available for email sign in."
            iconSystemName = "info.circle.fill"
            tint = Color.appTextSecondary
        }
    }
}
