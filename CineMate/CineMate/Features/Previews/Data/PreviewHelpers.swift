//
//  PreviewHelpers.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-20.
//

import SwiftUI

/// Preview helpers for shared environment setup.
extension View {
    /// Injects the shared preview environment.
    @MainActor
    func withPreviewEnvironment() -> some View {
        withPreviewEnvironment(
            navigator: AppNavigator(),
            toastCenter: ToastCenter()
        )
    }

    /// Injects a provided preview environment.
    @MainActor
    func withPreviewEnvironment(
        navigator: AppNavigator,
        toastCenter: ToastCenter
    ) -> some View {
        self
            .environmentObject(navigator)
            .environmentObject(toastCenter)
    }

    /// Wraps the view in preview navigation.
    @MainActor
    func withPreviewNavigation() -> some View {
        PreviewNavigationHost(content: self)
    }

    /// Injects the preview environment without navigation.
    @MainActor
    func withPreviewToasts() -> some View {
        withPreviewEnvironment()
    }
}

@MainActor
private struct PreviewNavigationHost<Content: View>: View {
    let content: Content

    @StateObject private var navigator = AppNavigator()
    @StateObject private var toastCenter = ToastCenter()

    var body: some View {
        NavigationStack(path: $navigator.path) {
            content
                .navigationDestination(for: AppRoute.self) { route in
                    PreviewNavigationDestination(route: route)
                }
        }
        .withPreviewEnvironment(navigator: navigator, toastCenter: toastCenter)
    }
}

@MainActor
private struct PreviewNavigationDestination: View {
    let route: AppRoute

    var body: some View {
        switch route {
        case .movie(let id):
            movieDestination(for: id)
        case .person(let id):
            personDestination(for: id)
        case .genre(let id, let name):
            GenreDetailView(
                genreId: id,
                genreName: name,
                repository: PreviewFactory.repository
            )
        case .seeAllMovies(let title, let source):
            seeAllMoviesDestination(title: title, source: source)
        case .createAccount:
            CreateAccountView(createViewModel: PreviewFactory.createEmpty())
        }
    }

    private func movieDestination(for id: Int) -> some View {
        let movieViewModel = PreviewFactory.movieListViewModel()
        if movieViewModel.movie(by: id) == nil {
            movieViewModel.cacheStub(previewMovieStub(id: id))
        }

        return MovieDetailView(
            movieId: id,
            movieViewModel: movieViewModel,
            castViewModel: PreviewFactory.castViewModel(),
            favoriteViewModel: PreviewFactory.favoritesViewModel()
        )
    }

    private func personDestination(for id: Int) -> some View {
        CastMemberDetailView(
            member: previewCastMember(id: id),
            personViewModel: PersonViewModel(repository: PreviewFactory.repository),
            favoritePeopleVM: PreviewFactory.favoritePeopleDefaultVM(),
            movieViewModel: PreviewFactory.movieListViewModel()
        )
    }

    private func seeAllMoviesDestination(title: String, source: SeeAllMoviesSource) -> some View {
        let viewModel = SeeAllMoviesViewModel(repository: PreviewFactory.repository, source: source)
        viewModel.movies = SharedPreviewMovies.moviesList.removingDuplicateIDs()
        return SeeAllMoviesView(viewModel: viewModel, title: title)
    }

    private func previewMovieStub(id: Int) -> Movie {
        Movie(
            id: id,
            title: "Preview Movie \(id)",
            overview: "Offline preview stub for navigation.",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "2025-01-01",
            voteAverage: 7.5,
            genres: nil
        )
    }
    
    private func previewCastMember(id: Int) -> CastMember {
        if let castMember = MovieCreditsPreviewData.starWarsCredits().cast.first(where: { $0.id == id }) {
            return castMember
        }

        return CastMember(
            id: id,
            name: "Preview Person \(id)",
            character: nil,
            profilePath: nil
        )
    }
}
