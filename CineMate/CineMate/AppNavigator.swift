//
//  AppNavigator.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

@MainActor
final class AppNavigator: ObservableObject {
    // Binds to NavigationStack in RootView
    @Published var path: [AppRoute] = []

    func goToMovie(_ movie: Movie) {
        pushOrReplace(.movie(id: movie.id))
    }
    func goToPerson(_ castMember: CastMember) {
        pushOrReplace(.person(id: castMember.id))
    }
    func goToCrew(_ crew: CrewMember) {
        pushOrReplace(.person(id: crew.id))
    }
    func goToGenre(_ name: String) {
        pushOrReplace(.genre(name: name))
    }


    private func pushOrReplace(_ route: AppRoute) {
        replaceLast(ofKind: route.caseName, with: route)
    }

    /// Pops **one** level off the stack. Handy if you need a custom back-button
    /// outside of SwiftUI’s default navigation bar.
    func goBack() {
        _ = path.popLast()
    }

    /// Clears the entire navigation stack – typically called whenever the user
    /// switches tab so each tab gets a *fresh* root view.
    func reset() {
        path.removeAll()
    }

    /// Replaces the last route of a given kind with a new one, or appends if none exists.
    /// - Parameters:
    ///   - kind: The route case name (e.g., "movie", "person") used to identify matching entries.
    ///   - route: The new route to apply.
    func replaceLast(ofKind kind: String, with route: AppRoute) {
        if let i = path.lastIndex(where: { $0.caseName == kind }) {
            path[i] = route
            path.removeSubrange(i+1 ..< path.count)
        } else {
            path.append(route)
        }
    }
//    navigate through id
    func goToMovie(id: Int) {
        pushOrReplace(.movie(id: id))
    }

    func goToPerson(id: Int) {
        pushOrReplace(.person(id: id))
    }

    func goToCrew(id: Int) {
        pushOrReplace(.person(id: id))
    }
}
