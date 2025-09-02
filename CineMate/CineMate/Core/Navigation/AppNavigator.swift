//
//  AppNavigator.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

/// Centralized enum-based navigator driving navigation via a shared
/// `NavigationStack` (bound in `RootView`). All destination changes are
/// represented as `AppRoute` values that are either pushed or replace the
/// existing route of the same kind.
@MainActor
final class AppNavigator: ObservableObject {
    /// The current navigation path that SwiftUI observes.
    @Published var path: [AppRoute] = []

    // MARK: - Public navigation helpers

    /// Navigate to a view screen where user can create an account.
    func goToCreateAccount() {
        log("[Navigator] goToCreateAccount")
        pushOrReplace(.createAccount)
    }

    /// Navigate to a genre screen by name.
    func goToGenre(_ name: String) {
        log("[Navigator] goToGenre: \(name)")
        pushOrReplace(.genre(name: name))
    }

    /// Navigate to a movie by its ID.
    func goToMovie(id: Int) {
        log("[Navigator] goToMovie(id: \(id))")
        pushOrReplace(.movie(id: id))
        logCurrentPath()
    }

    /// Navigate to a person (cast/crew) by their ID.
    func goToPerson(id: Int) {
        log("[Navigator] goToPerson(id: \(id))")
        pushOrReplace(.person(id: id))
        logCurrentPath()
    }

    /// Navigate to a crew member; internally treated as a person route.
    func goToCrew(id: Int) {
        log("[Navigator] goToCrew(id: \(id))")
        pushOrReplace(.person(id: id))
        logCurrentPath()
    }

    /// Navigate to ...
    func goToSeeAllMovies(title: String, filter: DiscoverFilter) {
        log("[Navigator] goToSeeAllMovies: \(title)")
        pushOrReplace(.seeAllMovies(title: title, filter: filter))
    }
    /// Pop one level from the navigation stack.
    func goBack() {
        log("[Navigator] goBack (before): \(describePath())")
        _ = path.popLast()
        log("[Navigator] goBack (after): \(describePath())")
    }

    /// Clear the entire navigation stack (e.g., when switching tabs).
    func reset() {
        log("[Navigator] reset navigation stack")
        path.removeAll()
    }

    // MARK: - Internal

    /// Pushes or replaces the last route of the same kind.
    private func pushOrReplace(_ route: AppRoute) {
        log("[Navigator] pushOrReplace requested for: \(route)")
        replaceLast(ofKind: route.caseName, with: route)
    }

    /// Replaces the last route of the given kind with a new one, or appends if none exists.
    /// - Parameters:
    ///   - kind: The route case name (e.g., "movie", "person") used to identify matches.
    ///   - route: The new route to apply.
    func replaceLast(ofKind kind: String, with route: AppRoute) {
        log("[Navigator] replaceLast of kind '\(kind)' with \(route); current path: \(describePath())")
        if let i = path.lastIndex(where: { $0.caseName == kind }) {
            path[i] = route
            path.removeSubrange(i + 1 ..< path.count)
        } else {
            path.append(route)
        }
        log("[Navigator] new path: \(describePath())")
    }

    // MARK: - Debug / Logging helpers

    private func log(_ message: String) {
        print(message)
    }

    private func logCurrentPath() {
        print("[Navigator] current path snapshot: \(describePath())")
    }

    private func describePath() -> String {
        guard !path.isEmpty else { return "⟨empty⟩" }
        return path.enumerated()
            .map { index, route in
                "[\(index)] \(type(of: route)) \(route)"
            }
            .joined(separator: " -> ")
    }
}
