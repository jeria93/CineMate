//
//  DebugLoginCredentials.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-05-22.
//

import Foundation

#if DEBUG
enum DebugLoginCredentials {
    private static let environment = ProcessInfo.processInfo.environment

    static var email: String? { sanitize(environment["DEBUG_LOGIN_EMAIL"]) }
    static var password: String? { sanitize(environment["DEBUG_LOGIN_PASSWORD"]) }

    private static func sanitize(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
#endif
