//
//  AppNavigator.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

/// AppNavigator
/// -------------
/// A single, observable “GPS” for the entire app.
/// * `path` is the live history that backs the shared `NavigationStack`.
/// * The `goTo…` helpers append enum routes, centralising navigation logic.
/// * `goBack`/`reset` manipulate the stack without exposing `NavigationPath` directly.
///
/// Inject **one** instance with `.environmentObject(navigator)` at the root,
/// then call the helpers from any view without scattering `NavigationLink`s.
@MainActor
final class AppNavigator: ObservableObject {

    /// Current navigation stack, reflected by `NavigationStack(path:)` in **RootView**.
    @Published var path: [AppRoute] = []

    // MARK: - Route helpers
    // ---------------------

    /// Pushes a **`MovieDetailView`** for the supplied `Movie`.
    func goToMovie(_ movie: Movie) {
        path.append(.movieDetails(movie))
    }

    /// Pushes a **`CastMemberDetailView`** for the tapped cast member (actor/actress).
    func goToPerson(_ member: CastMember) {
        path.append(.personDetails(member))
    }

    /// Pushes a **`CastMemberDetailView`** for a crew member (e.g. director).
    /// The actual mapping `CrewMember → CastMember` happens where the helper is called.
    func goToCrew(_ crew: CrewMember) {
        path.append(.crewDetails(crew))
    }

    /// Pushes a **`GenreDetailView`** for the selected genre name.
    /// Used when a user taps on a genre (e.g. "Action") to see
    /// movies belonging to that genre.
    ///
    /// The `genre` parameter is the display name of the genre.
    func goToGenre(_ genre: String) {
        path.append(.genreDetails(genre))
    }

    // MARK: - Stack control
    // ---------------------

    /// Pops the last destination (1-step “Back”).
    func goBack() {
        _ = path.popLast()
    }

    /// Clears the entire stack (back to root tab).
    func reset() {
        path.removeAll()
    }
}
