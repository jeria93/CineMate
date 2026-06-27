//
//  AccountSecurityStatus.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-06-03.
//

import SwiftUI

/// Maps available security actions into concise copy, icon, and tint for the account UI.
struct AccountSecurityStatus {
    private enum Kind {
        case emailAccount
        case limitedControls

        init(canChangeEmail: Bool, canSendPasswordReset: Bool) {
            self = canChangeEmail && canSendPasswordReset ? .emailAccount : .limitedControls
        }

        var title: String {
            switch self {
            case .emailAccount:
                return "Email account"
            case .limitedControls:
                return "Limited controls"
            }
        }

        var detail: String {
            switch self {
            case .emailAccount:
                return "Email changes and password reset links are available for this account."
            case .limitedControls:
                return "Some security actions are only available for email sign in."
            }
        }

        var iconSystemName: String {
            switch self {
            case .emailAccount:
                return "checkmark.shield.fill"
            case .limitedControls:
                return "info.circle.fill"
            }
        }

        var tint: Color {
            switch self {
            case .emailAccount:
                return Color.appPositive
            case .limitedControls:
                return Color.appTextSecondary
            }
        }
    }

    let title: String
    let detail: String
    let iconSystemName: String
    let tint: Color
    
    init(canChangeEmail: Bool, canSendPasswordReset: Bool) {
        let kind = Kind(
            canChangeEmail: canChangeEmail,
            canSendPasswordReset: canSendPasswordReset
        )
        title = kind.title
        detail = kind.detail
        iconSystemName = kind.iconSystemName
        tint = kind.tint
    }
}
