//
//  PersonRef.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-11.
//

import Foundation

/// # PersonRef
/// Lightweight DTO stored in Firestore for favorite people. Decoupled from TMDB `PersonDetail`.
struct PersonRef: Identifiable, Hashable, Codable {
    /// TMDB person identifier.
    let id: Int
    /// Display name for the person.
    let name: String
    /// Optional TMDB image path for the profile.
    let profilePath: String?

    /// Resolved image URL for rendering in UI (returns nil if `profilePath` is missing).
    var profileURL: URL? {
        TMDBImageHelper.url(for: profilePath, size: .h632)
    }
}
