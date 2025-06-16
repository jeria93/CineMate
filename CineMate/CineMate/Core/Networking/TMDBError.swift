//
//  TMDBError.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-16.
//

import Foundation

enum TMDBError: Error, LocalizedError {

    case badURL
    case invalidResponse
    case decodingFailed
    case serverError(Int)
    case missingSecrets
    case unknown

    var errorDescription: String? {
        switch self {
        case .badURL:
            return "The URL was invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .decodingFailed:
            return "Failed to decode the response data."
        case .serverError(let code):
            return "Server responded with error code: \(code)."
        case .missingSecrets:
            return "API key or bearer token is missing."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
