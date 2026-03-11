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
/// top route when the same route kind is requested.
@MainActor
final class AppNavigator: ObservableObject {
    /// The current navigation path that SwiftUI observes.
    @Published var path: [AppRoute] = []
    
    // MARK: - Public navigation helpers
    
    /// Navigate to a view screen where user can create an account.
    func goToCreateAccount() {
        pushOrReplace(.createAccount)
    }
    
    /// Navigate to a genre screen by name.
    func goToGenre(_ name: String) {
        pushOrReplace(.genre(name: name))
    }
    
    /// Navigate to a movie by its ID.
    func goToMovie(id: Int) {
        pushOrReplace(.movie(id: id))
    }
    
    /// Navigate to a person (cast/crew) by their ID.
    func goToPerson(id: Int) {
        pushOrReplace(.person(id: id))
    }
    
    /// Navigate to a crew member; internally treated as a person route.
    func goToCrew(id: Int) {
        pushOrReplace(.person(id: id))
    }
    
    /// Navigate to a full list screen from a discover section.
    func goToSeeAllMovies(title: String, filter: DiscoverFilter) {
        pushOrReplace(.seeAllMovies(title: title, filter: filter))
    }
    
    /// Pop one level from the navigation stack.
    func goBack() {
        guard !path.isEmpty else {
            log("goBack ignored (path already empty)")
            return
        }
        let before = describePath()
        let popped = path.removeLast()
        log("pop \(popped) | \(before) -> \(describePath())")
    }
    
    /// Clear the entire navigation stack (e.g., when switching tabs).
    func reset(reason: String = "manual") {
        replacePath(with: [], reason: reason)
    }
    
    /// Replace the entire navigation path with a new one.
    /// Used for deterministic tab path restore/reset behavior.
    func replacePath(with newPath: [AppRoute], reason: String = "manual") {
        guard path != newPath else {
            log("setPath skipped (\(reason), no changes)")
            return
        }
        let before = describePath()
        path = newPath
        log("setPath (\(reason)) | \(before) -> \(describePath())")
    }
    
    // MARK: - Internal
    
    /// Pushes a route, or replaces the top route if it is the same route kind.
    /// If the top route is already equal to `route`, this is a no-op.
    private func pushOrReplace(_ route: AppRoute) {
        let before = describePath()
        guard let top = path.last else {
            path.append(route)
            log("push \(route) | \(before) -> \(describePath())")
            return
        }
        
        if top.kind == route.kind {
            guard top != route else {
                log("noop \(route) already on top")
                return
            }
            path[path.count - 1] = route
            log("replaceTop \(top) -> \(route) | \(before) -> \(describePath())")
        } else {
            path.append(route)
            log("push \(route) | \(before) -> \(describePath())")
        }
    }
    
    // MARK: - Debug / Logging helpers
    
    private func log(_ message: String) {
#if DEBUG
        print("[App][Nav][Navigator] \(message)")
#endif
    }
    
    private func describePath() -> String {
        guard !path.isEmpty else { return "[]" }
        return path.map(\.description).joined(separator: " -> ")
    }
}
