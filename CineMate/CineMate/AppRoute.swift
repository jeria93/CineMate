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

    /// Opens **`MovieDetailView`** for the selected `Movie`.
    case movieDetails(Movie)

    /// Opens **`CastMemberDetailView`** for a `CastMember`
    /// (i.e. an actor/actress tapped in a cast list).
    case personDetails(CastMember)

    /// Opens **`CastMemberDetailView`** for a `CrewMember`
    /// (e.g. director, writer) after it has been mapped to a `CastMember`
    /// via `CastMember(init from:)`.
    case crewDetails(CrewMember)
}
