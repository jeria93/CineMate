//
//  PersonDetail.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import Foundation

/// Detailed information about a person (e.g. actor, director).
/// Endpoint: https://developer.themoviedb.org/reference/person-details
struct PersonDetail: Codable, Identifiable {
    private enum Gender: Int {
        case notSpecified = 0
        case female = 1
        case male = 2

        var displayText: String {
            switch self {
            case .female:
                return "Female"
            case .male:
                return "Male"
            case .notSpecified:
                return "Not specified"
            }
        }
    }

    let id: Int
    let name: String
    let birthday: String?
    let deathday: String?
    let biography: String?
    let placeOfBirth: String?
    let profilePath: String?
    let imdbId: String?
    let gender: Int?
    let knownForDepartment: String?
    let alsoKnownAs: [String]

    var profileURL: URL? {
        TMDBImageHelper.url(for: profilePath, size: .w342)
    }

    var imdbURL: URL? {
        guard let imdbId else { return nil }
        return URL(string: "https://www.imdb.com/name/\(imdbId)")
    }

    var tmdbURL: URL? {
        return URL(string: "https://www.themoviedb.org/person/\(id)")
    }

    var safeGenderText: String? {
        gender.flatMap { Gender(rawValue: $0)?.displayText }
    }

    var hasAliases: Bool {
        !alsoKnownAs.isEmpty
    }
}
