//
//  SearchValidationResult+Message.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-07.
//

import Foundation

extension SearchValidationResult {
    /// Whether the result is valid or not
    var isValid: Bool {
        if case .valid = self { return true }
        return false
    }

    /// The trimmed version of the valid query (if any)
    var trimmed: String? {
        if case .valid(let trimmed) = self { return trimmed }
        return ""
    }
    
    /// The validation message to show to user (if any)
    var message: String? {
        switch self {
        case .tooShort(let min): return "Query must be at least \(min) characters."
        case .tooLong(let max): return "Query must be less than \(max) characters."
        case .invalidCharacters: return "Only letters and numbers are allowed."
        default: return nil
        }
    }
}
