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
    case noResults
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .networkFailure:
            return "Could not load search results. Try again."
        case .invalidResponse:
            return "The server returned invalid data."
        case .noResults:
            return "No movies found for your search."
        case .custom(let message):
            return message
        }
    }
}
