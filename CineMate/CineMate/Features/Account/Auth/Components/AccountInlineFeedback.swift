//
//  AccountInlineFeedback.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-06-03.
//

import SwiftUI

/// Small feedback model used by account sections to render local success or error messages.
struct AccountInlineFeedback {
    private enum Kind {
        case success
        case error

        var color: Color {
            switch self {
            case .success:
                return .appPositive
            case .error:
                return .appDestructive
            }
        }
    }

    let message: String
    private let kind: Kind

    var color: Color {
        kind.color
    }

    private init(message: String, kind: Kind) {
        self.message = message
        self.kind = kind
    }
    
    static func success(_ message: String) -> Self {
        Self(message: message, kind: .success)
    }
    
    static func error(_ message: String) -> Self {
        Self(message: message, kind: .error)
    }
}
