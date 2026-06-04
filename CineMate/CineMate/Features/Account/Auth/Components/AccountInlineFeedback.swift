//
//  AccountInlineFeedback.swift
//  CineMate
//
//  Created by OpenAI Codex on 2026-06-03.
//

import SwiftUI

/// Small feedback model used by account sections to render local success or error messages.
struct AccountInlineFeedback {
    let message: String
    let color: Color
    
    static func success(_ message: String) -> Self {
        Self(message: message, color: .appPositive)
    }
    
    static func error(_ message: String) -> Self {
        Self(message: message, color: .appDestructive)
    }
}
