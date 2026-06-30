//
//  AccountLegalStatus.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-06-03.
//

import SwiftUI

/// Maps legal acceptance state into concise copy, icon, and tint for the account UI.
struct AccountLegalStatus {
    private enum Kind {
        case missing
        case outdated
        case accepted

        init(summaryText: String?, isOutdated: Bool) {
            if summaryText == nil {
                self = .missing
            } else if isOutdated {
                self = .outdated
            } else {
                self = .accepted
            }
        }

        var title: String {
            switch self {
            case .missing:
                return "Missing"
            case .outdated:
                return "Outdated"
            case .accepted:
                return "Accepted"
            }
        }

        var detail: String {
            switch self {
            case .missing:
                return "No saved legal acceptance for this account yet."
            case .outdated:
                return "Review and accept the latest terms to keep your account up to date."
            case .accepted:
                return "Your saved legal acceptance is current."
            }
        }

        var iconSystemName: String {
            switch self {
            case .missing:
                return "exclamationmark.circle.fill"
            case .outdated:
                return "clock.badge.exclamationmark.fill"
            case .accepted:
                return "checkmark.seal.fill"
            }
        }

        var tint: Color {
            switch self {
            case .missing:
                return Color.appDestructive
            case .outdated:
                return AuthTheme.warningOnCurtain
            case .accepted:
                return Color.appPositive
            }
        }
    }

    let title: String
    let detail: String
    let acceptedAtText: String?
    let iconSystemName: String
    let tint: Color
    
    init(summaryText: String?, acceptedAtText: String?, isOutdated: Bool) {
        let kind = Kind(summaryText: summaryText, isOutdated: isOutdated)
        self.acceptedAtText = acceptedAtText
        title = kind.title
        detail = kind.detail
        iconSystemName = kind.iconSystemName
        tint = kind.tint
    }
}
