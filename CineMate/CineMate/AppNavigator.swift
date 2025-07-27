//
//  AppNavigator.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

/// AppNavigator
/// -------------
/// Central navigation controller for the entire app.
/// Replaces the need for scattered `NavigationLink`s by offering:
///
/// • `smartReplace(...)` to avoid duplicate views on stack
/// • `pushIfNeeded(...)` to avoid stacking the same route
/// • `replaceLast(...)` for manual control
///
/// Inject once with `.environmentObject(AppNavigator())`
/// and call `goTo...()` methods from anywhere.
@MainActor
final class AppNavigator: ObservableObject {

    /// The current stack of routes managed by NavigationStack
    @Published var path: [AppRoute] = []

    // MARK: - Route Helpers
    // ---------------------

    /// Navigate to a movie detail screen.
    /// Smartly replaces top view if already movie/person.
    func goToMovie(_ movie: Movie) {
        smartReplace(.movieDetails(movie))
    }

    /// Navigate to a person (cast member) detail screen.
    /// Replaces top view if already showing a person.
    func goToPerson(_ member: CastMember) {
        smartReplace(.personDetails(member))
    }

    /// Navigate to a crew member by converting to a CastMember.
    func goToCrew(_ crew: CrewMember) {
        let castMember = CastMember(from: crew)
        smartReplace(.personDetails(castMember))
    }

    /// Navigate to a genre detail screen.
    /// Only pushes if genre isn’t already top of stack.
    func goToGenre(_ genre: String) {
        smartReplace(.genreDetails(genre))
    }

    // MARK: - Stack Control
    // ---------------------

    /// Go back one view
    func goBack() {
        _ = path.popLast()
    }

    /// Clear entire stack (return to root)
    func reset() {
        path.removeAll()
    }

    /// Replaces the top route with a new one (unconditionally)
    func replaceLast(with route: AppRoute) {
        if path.last != nil {
            path.removeLast()
        }
        path.append(route)
    }
}

// MARK: - Smart Routing Helpers
// -----------------------------

extension AppNavigator {

    /// Appends a route if it’s not already the topmost view
    func pushIfNeeded(_ route: AppRoute) {
        if path.last != route {
            path.append(route)
        }
    }

    /// Replaces the top route with new route *only* if they are of same type or person/movie mix
    func smartReplace(_ route: AppRoute) {
        guard let last = path.last else {
            path.append(route)
            return
        }

        if shouldReplace(last: last, with: route) {
            replaceLast(with: route)
        } else if last != route {
            path.append(route)
        }
    }

    /// Determines when we should replace top instead of pushing
    private func shouldReplace(last: AppRoute, with new: AppRoute) -> Bool {
        switch (last, new) {
        case (.movieDetails, .movieDetails),
             (.personDetails, .personDetails),
             (.personDetails, .movieDetails),
             (.movieDetails, .personDetails),
             (.genreDetails, .genreDetails):
            return true
        default:
            return false
        }
    }
}
