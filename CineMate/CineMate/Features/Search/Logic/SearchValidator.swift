//
//  SearchValidator.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-07.
//

import Foundation

/// Validation result for a search query.
enum SearchValidationResult {
    case valid(trimmed: String)
    case empty
    case tooShort(minLength: Int)
    case tooLong(maxLength: Int)
    case invalidCharacters
}

/// Rules for search input.
struct SearchValidator {
    static let minLength = 2
    static let maxLength = 50

    private static let allowedCharacterSet = CharacterSet.letters
        .union(.decimalDigits)
        .union(.whitespaces)
        .union(CharacterSet(charactersIn: "-':&!?,."))

    /// Cleans search text while typing.
    /// Keeps allowed characters, removes leading spaces, and limits length.
    static func sanitizedInput(_ input: String) -> String {
        let filteredScalars = input.unicodeScalars.filter { scalar in
            allowedCharacterSet.contains(scalar)
        }
        let filtered = String(String.UnicodeScalarView(filteredScalars))
        let withoutLeadingSpaces = filtered.replacingOccurrences(
            of: #"^\s+"#,
            with: "",
            options: .regularExpression
        )
        return String(withoutLeadingSpaces.prefix(maxLength))
    }

    /// Validates query text used for search requests.
    static func validate(_ query: String) -> SearchValidationResult {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return .empty
        }

        let normalized = normalizeWhitespaces(in: trimmed)

        guard normalized.count >= minLength else {
            return .tooShort(minLength: minLength)
        }

        guard normalized.count <= maxLength else {
            return .tooLong(maxLength: maxLength)
        }

        if normalized.rangeOfCharacter(from: allowedCharacterSet.inverted) != nil {
            return .invalidCharacters
        }

        return .valid(trimmed: normalized)
    }

    private static func normalizeWhitespaces(in input: String) -> String {
        input.replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )
    }
}
