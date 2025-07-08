//
//  SearchValidator.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-07.
//

import Foundation

/// Represents the outcome of a search query validation.
enum SearchValidationResult {
    case valid(trimmed: String)
    case empty
    case tooShort(minLength: Int)
    case tooLong(maxLength: Int)
    case invalidCharacters
}

/// A utility for validating search queries before they are sent to the API.
struct SearchValidator {
    /// Validates a given query string and returns a `SearchValidationResult`.
    /// - Parameter query: The user input to validate.
    /// - Returns: A validation result with either `.valid(trimmed:)` or a failure case.
    static func validate(_ query: String) -> SearchValidationResult {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return .empty
        }

        guard trimmed.count >= 2 else {
            return .tooShort(minLength: 2)
        }

        guard trimmed.count <= 50 else {
            return .tooLong(maxLength: 50)
        }

        let allowedCharacterSet = CharacterSet.letters
            .union(.decimalDigits)
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "-':&!?,."))

        if trimmed.rangeOfCharacter(from: allowedCharacterSet.inverted) != nil {
            return .invalidCharacters
        }

        return .valid(trimmed: trimmed)
    }
}
