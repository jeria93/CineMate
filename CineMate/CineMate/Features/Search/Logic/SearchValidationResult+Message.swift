//
//  SearchValidationResult+Message.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-07.
//

import Foundation

extension SearchValidationResult {
    /// The trimmed version of the valid query (if any)
    var trimmed: String? {
        if case .valid(let trimmed) = self { return trimmed }
        return nil
    }

    /// The validation message to show to user (if any)
    var message: String? {
        switch self {
        case .tooShort(let min):
            return "Enter at least \(min) characters."
        case .tooLong(let max):
            return "Use \(max) characters or fewer."
        case .invalidCharacters:
            return "Use letters, numbers, spaces, and basic punctuation."
        default: return nil
        }
    }
}
