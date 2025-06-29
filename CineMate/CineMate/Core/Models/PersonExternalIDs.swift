//
//  PersonExternalIDs.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-28.
//

import Foundation

/// Social media and external IDs for a person
/// Endpoint: https://developer.themoviedb.org/reference/person-external-ids
struct PersonExternalIDs: Codable {
    let instagramId: String?
    let twitterId: String?
    let facebookId: String?
    let imdbId: String?

    var instagramURL: URL? {
        guard let instagramId else { return nil }
        return URL(string: "https://www.instagram.com/\(instagramId)")
    }

    var twitterURL: URL? {
        guard let twitterId else { return nil }
        return URL(string: "https://twitter.com/\(twitterId)")
    }

    var facebookURL: URL? {
        guard let facebookId else { return nil }
        return URL(string: "https://www.facebook.com/\(facebookId)")
    }
}

extension PersonExternalIDs {
    static let preview = PersonExternalIDs(
        instagramId: "hamillhimself",
        twitterId: "HamillHimself",
        facebookId: "MarkHamill",
        imdbId: "nm0000434"
    )
}
