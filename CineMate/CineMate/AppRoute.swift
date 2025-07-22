//
//  AppRoute.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import Foundation
/// AppRoute
/// ---------
/// Enum of all screens that can be pushed in `NavigationStack`.
/// Add a new case whenever you create a new destination view.
enum AppRoute: Hashable {
    /// Opens `MovieDetailView` for the given movie.
    case movieDetails(Movie)
    case personDetails(CastMember)
}
/*

 Navigation views:
 MovieGenresView
 DiscoverSectionView
 RelatedMoviesSection
 CastMemberView
 MovieListContentView
 DirectorView


 */
