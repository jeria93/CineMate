//
//  SearchError.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-08.
//

import Foundation

/// Represents different types of search-related errors in the app.
enum SearchError: LocalizedError, Equatable {

    case networkFailure
    case invalidResponse
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .networkFailure:
            return "Could not load search results. Check your connection and try again."
        case .invalidResponse:
            return "Received an unexpected response. Please try again."
        case .custom(let message):
            return message
        }
    }
}
