//
//  AppNavigator.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI
/// Centralised navigation controller using enum routes.
final class AppNavigator: ObservableObject {
    /// Stack of routes rendered by `NavigationStack`.
    @Published var path: [AppRoute] = []

    /// Pushes **MovieDetail** for the given movie.
    func goToMovie(movie: Movie) {
        path.append(.movieDetails(movie))
    }

    /// Pops the last route (one step back).
    func goBack() {
        _ = path.popLast()
    }

    /// Clears the whole stack (back to root).
    func reset() {
        path.removeAll()
    }
}
/// AppNavigator
/// -------------
/// A shared “GPS” for enum-based navigation.
/// • `path` – current NavigationStack history
/// • `goToMovie` – push `.movieDetails`
/// • `goBack` / `reset` – pop or clear the stack
///
/// Injected once as `@EnvironmentObject`; any view can trigger
/// navigation without direct links.
