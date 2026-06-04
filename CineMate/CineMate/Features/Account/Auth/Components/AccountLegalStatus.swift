//
//  AccountLegalStatus.swift
//  CineMate
//
//  Created by OpenAI Codex on 2026-06-03.
//

import SwiftUI

/// Maps legal acceptance state into concise copy, icon, and tint for the account UI.
struct AccountLegalStatus {
    let title: String
    let detail: String
    let acceptedAtText: String?
    let iconSystemName: String
    let tint: Color
    
    init(summaryText: String?, acceptedAtText: String?, isOutdated: Bool) {
        self.acceptedAtText = acceptedAtText
        
        if summaryText == nil {
            title = "Missing"
            detail = "No saved legal acceptance for this account yet."
            iconSystemName = "exclamationmark.circle.fill"
            tint = Color.appDestructive
        } else if isOutdated {
            title = "Outdated"
            detail = "Review and accept the latest terms to keep your account up to date."
            iconSystemName = "clock.badge.exclamationmark.fill"
            tint = AuthTheme.warningOnCurtain
        } else {
            title = "Accepted"
            detail = "Your saved legal acceptance is current."
            iconSystemName = "checkmark.seal.fill"
            tint = Color.appPositive
        }
    }
}
