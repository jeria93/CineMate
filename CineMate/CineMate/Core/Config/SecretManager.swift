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

    private enum Key {
        static let apiKey = "TMDB_API_KEY"
        static let bearerToken = "TMDB_BEARER_TOKEN"
    }

    private static let secretsResult: Result<[String: String], Error> = {
        do {
            return .success(try readSecretsFromPlist())
        } catch {
            return .failure(error)
        }
    }()

    /// Loads a value from `Secrets.plist` based on the provided key.
    /// - Parameter key: The name of the key in `Secrets.plist`
    /// - Returns: The associated value as a non-empty `String`.
    static func load(_ key: String) throws -> String {
        guard let value = try valueIfPresent(for: key) else {
            throw TMDBError.missingSecrets
        }
        return value
    }

    /// TMDB API key loaded from `Secrets.plist`
    static var apiKey: String { requiredValue(for: Key.apiKey) }

    /// TMDB Bearer token loaded from `Secrets.plist`
    static var bearerToken: String { requiredValue(for: Key.bearerToken) }

    /// `true` when a non-empty bearer token can be resolved.
    static var hasBearerToken: Bool {
        do {
            return try valueIfPresent(for: Key.bearerToken) != nil
        } catch {
            return false
        }
    }
}

private extension SecretManager {
    static func requiredValue(for key: String) -> String {
        do {
            return try load(key)
        } catch {
            preconditionFailure(
                "Missing required secret '\(key)' in Secrets.plist. " +
                "Ensure the file exists and contains a non-empty value."
            )
        }
    }

    static func valueIfPresent(for key: String) throws -> String? {
        let secrets: [String: String]
        switch secretsResult {
        case .success(let loaded):
            secrets = loaded
        case .failure:
            throw TMDBError.missingSecrets
        }

        guard let rawValue = secrets[key] else { return nil }
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return trimmed
    }

    static func readSecretsFromPlist() throws -> [String: String] {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist") else {
            throw TMDBError.missingSecrets
        }

        let data = try Data(contentsOf: url)
        let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
        guard let dictionary = plist as? [String: Any] else {
            throw TMDBError.missingSecrets
        }

        var secrets: [String: String] = [:]
        for (key, value) in dictionary {
            if let stringValue = value as? String {
                secrets[key] = stringValue
            }
        }
        return secrets
    }
}
