//
//  AppRoute.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import Foundation

/// Defines which data source a "See all" screen should use.
enum SeeAllMoviesSource: Hashable {
    case discover(DiscoverFilter)
    case category(MovieCategory)
    case nowPlaying
}

/// AppRoute
/// ---------
/// All destinations that can be pushed onto the shared `NavigationStack`.
/// Whenever you add a new screen, introduce a matching case here *and* handle
/// it inside `RootView.navigationDestination`.
enum AppRoute: Hashable {
    case movie(id: Int)
    case person(id: Int)
    case genre(id: Int, name: String)
    case seeAllMovies(title: String, source: SeeAllMoviesSource)
    case createAccount
}

extension AppRoute {
    enum Kind: String {
        case movie
        case person
        case genre
        case seeAllMovies
        case createAccount
    }

    var kind: Kind {
        switch self {
        case .movie: .movie
        case .person: .person
        case .genre: .genre
        case .seeAllMovies: .seeAllMovies
        case .createAccount: .createAccount
        }
    }
}

extension AppRoute: CustomStringConvertible {
    var description: String {
        switch self {
        case .movie(let id):
            return "movie(id: \(id))"
        case .person(let id):
            return "person(id: \(id))"
        case .genre(let id, let name):
            return "genre(id: \(id), name: \(name))"
        case .seeAllMovies(let title, _):
            return "seeAllMovies(title: \(title))"
        case .createAccount:
            return "createAccount"
        }
    }
}
