//
//  SecretManager.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation

/// `SecretManager` is a utility that loads sensitive values from `Secrets.plist`.
/// Use it to securely access API keys, tokens, or other configuration values.
///
/// Example usage:
/// ```swift
/// let key = SecretManager.apiKey
/// let token = SecretManager.bearerToken
/// ```
enum SecretManager {

    /// Loads a value from `Secrets.plist` based on the provided key.
    /// - Parameter key: The name of the key in `Secrets.plist`
    /// - Returns: The associated value as a `String`, or crashes the app if missing
    static func load(_ key: String) -> String {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let value = plist[key] as? String
        else {
            fatalError("Missing value for key: \(key)")
        }

        return value
    }

    /// TMDB API key loaded from `Secrets.plist`
    static var apiKey: String { load("TMDB_API_KEY") }

    /// TMDB Bearer token loaded from `Secrets.plist`
    static var bearerToken: String { load("TMDB_BEARER_TOKEN") }
}
