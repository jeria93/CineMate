//
//  AppRoute.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import Foundation
/// AppRoute
/// ---------
/// All destinations that can be pushed onto the shared `NavigationStack`.
/// Whenever you add a new screen, introduce a matching case here *and* handle
/// it inside `RootView.navigationDestination`.
enum AppRoute: Hashable {
    case movie(id: Int)
    case person(id: Int)
    case genre(name: String)
    case seeAllMovies(title: String, filter: DiscoverFilter)
    case createAccount
}

extension AppRoute {
    var caseName: String {
        switch self {
        case .movie: "movie"
        case .person: "person"
        case .genre: "genre"
        case .seeAllMovies: "seeAllMovies"
        case .createAccount: "createAccount"
        }
    }
}
