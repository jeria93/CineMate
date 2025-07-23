//
//  RootView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

struct RootView: View {
    let movieViewModel: MovieViewModel
    let castViewModel: CastViewModel
    let favoriteMoviesViewModel: FavoriteMoviesViewModel
    let searchViewModel: SearchViewModel
    let accountViewModel: AccountViewModel
    let discoverViewModel: DiscoverViewModel
    let personViewModel: PersonViewModel

    @EnvironmentObject private var navigator: AppNavigator

    var body: some View {

        NavigationStack(path: $navigator.path) {
            TabView {
                MovieListView(viewModel: movieViewModel,
                              castViewModel: castViewModel)
                .tabItem { Label("Movies", systemImage: "film") }

                FavoriteMoviesView(viewModel: favoriteMoviesViewModel)
                    .tabItem { Label("Favorites", systemImage: "heart.fill") }

                DiscoverView(viewModel: discoverViewModel)
                    .tabItem { Label("Discover", systemImage: "safari") }

                SearchView(viewModel: searchViewModel)
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }

                AccountView(viewModel: accountViewModel)
                    .tabItem {
                        Label("Account", systemImage: "person.crop.circle")
                    }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .movieDetails(let movie):
                    MovieDetailView(movie: movie,viewModel: movieViewModel, castViewModel: castViewModel)

                case .personDetails(let member):
                    CastMemberDetailView(member: member, viewModel: personViewModel)

                case .crewDetails(let crew):
                    CastMemberDetailView(member: CastMember(from: crew), viewModel: personViewModel)
                }
            }
        }
    }
}
/// RootView
/// --------
/// UI shell + navigation bridge.
///
/// • `NavigationStack` is still the engine (animations, swipe-back, history).
/// • `AppNavigator.path` is our steering wheel – a single source of truth
///   that every view can push/pop via enum routes (`AppRoute`).
/// • `navigationDestination` translates those routes into real views.
///
/// Result: central, type-safe navigation without scattered `NavigationLink`s.

// MARK: - Convenience Initializer
//
// Transforms a `CrewMember` (e.g., a director) into a lightweight
// `CastMember`, allowing all people to be handled by the same views.
//
// Copies `id`, `name`, and `profilePath`
// Sets `character` to `nil` (not applicable for crew)
// Used, for example, in `DirectorView` -> `nav.goToCrew(...)`
extension CastMember {
    /// Creates a **pseudo-cast** instance from a `CrewMember`.
    ///
    /// ```swift
    /// let cast = CastMember(from: directorCrew)
    /// ```
    ///
    /// - Parameter crew: The crew member to convert.
    init(from crew: CrewMember) {
        self.init(
            id:          crew.id,
            name:        crew.name,
            character:   nil,             // crew has no "character" role
            profilePath: crew.profilePath
        )
    }
}
