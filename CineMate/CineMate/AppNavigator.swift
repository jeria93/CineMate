//
//  AppNavigator.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI
/// Centralised navigation controller using enum routes.
@MainActor
final class AppNavigator: ObservableObject {
    @Published var path: [AppRoute] = []

    func goToMovie(_ movie: Movie) {
        path.append(.movieDetails(movie))
    }
    func goToPerson(_ member: CastMember) {
        path.append(.personDetails(member))
    }

    func goBack() {
        _ = path.popLast()
    }
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
