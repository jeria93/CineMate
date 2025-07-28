//
//  AppNavigator.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

@MainActor
final class AppNavigator: ObservableObject {
    @Published var path: [AppRoute] = []

    // MARK: - Route Helpers

    func goToMovie(_ movie: Movie) {
        print("[Nav] goToMovie(\(movie.title))")
        smartReplace(.movieDetails(movie))
    }

    func goToPerson(_ member: CastMember) {
        print("[Nav] goToPerson(\(member.name))")
        smartReplace(.personDetails(member))
    }

    func goToCrew(_ crew: CrewMember) {
        print("[Nav] goToCrew(\(crew.name))")
        let castMember = CastMember(from: crew)
        smartReplace(.personDetails(castMember))
    }

    func goToGenre(_ genre: String) {
        print("[Nav] goToGenre(\(genre))")
        smartReplace(.genreDetails(genre))
    }

    // MARK: - Stack Control

    func goBack() {
        print("[Nav] goBack()")
        _ = path.popLast()
        print("[Nav] new stack: \(path)")
    }

    func reset() {
        print("[Nav] reset()")
        path.removeAll()
    }

    func replaceLast(with route: AppRoute) {
        print("[Nav] replaceLast(with: \(route))")
        if path.last != nil {
            path.removeLast()
        }
        path.append(route)
        print("[Nav] new stack: \(path)")
    }
}

extension AppNavigator {
    func pushIfNeeded(_ route: AppRoute) {
        print("[Nav] pushIfNeeded(\(route)) — current stack: \(path)")
        if path.last != route {
            path.append(route)
            print("[Nav] -> pushed, new stack: \(path)")
        } else {
            print("[Nav] -> already top, skipping push")
        }
    }

    func smartReplace(_ route: AppRoute) {
        print("[Nav] smartReplace(\(route)) — current top: \(String(describing: path.last))")
        guard let last = path.last else {
            path.append(route)
            print("[Nav] -> stack was empty, appended: \(path)")
            return
        }
        if shouldReplace(last: last, with: route) {
            replaceLast(with: route)
        } else if last != route {
            path.append(route)
            print("[Nav] -> not same, appended: \(path)")
        } else {
            print("[Nav] -> same as top, skipping")
        }
    }

    private func shouldReplace(last: AppRoute, with new: AppRoute) -> Bool {
        switch (last, new) {
        case
            (.movieDetails, .movieDetails),
            (.personDetails, .personDetails),
            (.personDetails, .movieDetails),
            (.movieDetails, .personDetails),
            (.crewDetails, .crewDetails),
            (.genreDetails, .genreDetails):
            return true
        default:
            return false
        }
    }
}
