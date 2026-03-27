//
//  MovieDetailView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-09.
//

import SwiftUI

struct MovieDetailView: View {
    let movieId: Int
    @ObservedObject var movieViewModel: MovieViewModel
    @ObservedObject var castViewModel: CastViewModel
    @ObservedObject var favoriteViewModel: FavoriteMoviesViewModel
    @StateObject private var detailViewModel: MovieDetailViewModel

    private var movie: Movie? {
        if let cachedMovie = movieViewModel.movie(by: movieId) {
            return cachedMovie
        }

        if let detail = detailViewModel.movieDetail, detail.id == movieId {
            return detail.asMovieStub
        }

        return nil
    }

    private var recommendations: [Movie] {
        detailViewModel.recommendedMovies
            .filter { $0.id != movieId }
            .removingDuplicateIDs()
    }

    init(
        movieId: Int,
        movieViewModel: MovieViewModel,
        castViewModel: CastViewModel,
        favoriteViewModel: FavoriteMoviesViewModel,
        detailViewModel: MovieDetailViewModel? = nil
    ) {
        self.movieId = movieId
        self.movieViewModel = movieViewModel
        self.castViewModel = castViewModel
        self.favoriteViewModel = favoriteViewModel

        let resolvedDetailVM = detailViewModel
        ?? MovieDetailViewModel(repository: movieViewModel.underlyingRepository)
        _detailViewModel = StateObject(wrappedValue: resolvedDetailVM)
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    Color.clear.frame(height: 1).id("TOP")

                    primaryContent

                    if movie != nil {
                        MovieCreditsSection(
                            movieId: movieId,
                            castViewModel: castViewModel,
                            onRetry: { Task { await castViewModel.loadCredits(for: movieId) } }
                        )

                        recommendationsContent
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            .onAppear {
                proxy.scrollTo("TOP", anchor: .top)
            }
            .onChange(of: movieId) { _, _ in
                proxy.scrollTo("TOP", anchor: .top)
            }
        }
        .task(id: movieId) {
            guard !ProcessInfo.processInfo.isPreview else { return }
            await loadDetailScreen()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(movie?.title ?? "Movie")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if detailViewModel.isLoading, movie != nil {
                ProgressView("Loading details…")
                    .tint(.appPrimaryAction)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.appSurface.opacity(0.96))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.appTextSecondary.opacity(0.20), lineWidth: 1)
                    )
            }
        }
    }

    @ViewBuilder
    private var primaryContent: some View {
        if let movie {
            PosterImageView(
                url: movie.posterLargeURL,
                title: movie.title,
                width: SharedUI.Size.posterLarge.width,
                height: SharedUI.Size.posterLarge.height,
                cornerRadius: SharedUI.Radius.medium,
                shadowRadius: 4
            )
            .overlay(alignment: .topTrailing) {
                MovieFavoriteButtonView(movie: movie, favoriteViewModel: favoriteViewModel)
            }

            MovieDetailInfoView(
                movie: movie,
                detail: detailViewModel.movieDetail,
                watchProviderAvailability: detailViewModel.watchProviderAvailability,
                isWatchProvidersLoading: detailViewModel.isWatchProvidersLoading,
                watchProviderErrorMessage: detailViewModel.watchProviderErrorMessage,
                isLoading: detailViewModel.isLoading
            )
            MovieDetailActionBarView(movie: movie, videos: detailViewModel.movieVideos)
        } else if detailViewModel.isLoading {
            LoadingView(title: "Loading movie…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 80)
        } else if let errorMessage = detailViewModel.errorMessage {
            ErrorMessageView(
                title: "Failed to load movie",
                message: errorMessage,
                onRetry: {
                    Task { await loadDetailScreen() }
                }
            )
            .padding(.top, 80)
        } else {
            EmptyStateView(
                systemImage: "film",
                title: "Movie unavailable",
                message: "No detail data was found for this movie.",
                actionTitle: "Reload",
                onAction: { Task { await loadDetailScreen() } }
            )
            .padding(.top, 80)
        }
    }

    @ViewBuilder
    private var recommendationsContent: some View {
        if detailViewModel.isLoading, recommendations.isEmpty {
            ProgressView("Loading recommendations…")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        } else if !recommendations.isEmpty {
            RelatedMoviesSection(movies: recommendations, movieViewModel: movieViewModel)
        } else if case .loaded = detailViewModel.state {
            Text("No recommendations available.")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        }
    }

    private func loadDetailScreen() async {
        async let detailLoad: Void = detailViewModel.load(movieId: movieId)
        async let creditsLoad: Void = castViewModel.loadCredits(for: movieId)
        _ = await (detailLoad, creditsLoad)

        if let stub = detailViewModel.movieStub, stub.id == movieId {
            movieViewModel.cacheStub(stub)
        }
    }
}

private struct MovieCreditsSection: View {
    let movieId: Int
    @ObservedObject var castViewModel: CastViewModel
    let onRetry: () -> Void

    private var isCurrentMovie: Bool {
        castViewModel.activeMovieID == movieId
    }

    private var currentCredits: MovieCredits? {
        guard isCurrentMovie else { return nil }
        return castViewModel.credits
    }

    private var hasAnyCredits: Bool {
        guard let currentCredits else { return false }
        return !currentCredits.cast.isEmpty || !currentCredits.crew.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if castViewModel.isLoading, currentCredits == nil {
                ProgressView("Loading credits…")
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if let errorMessage = castViewModel.errorMessage, currentCredits == nil, isCurrentMovie {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Could not load credits")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                    Button("Retry Credits", action: onRetry)
                        .buttonStyle(.bordered)
                        .tint(.appPrimaryAction)
                }
            } else if hasAnyCredits, let currentCredits {
                MovieCreditsView(credits: currentCredits)
                if let director = currentCredits.crew.first(where: { $0.job == "Director" }) {
                    DirectorView(director: director)
                }
                CastCarouselView(cast: currentCredits.cast)
            } else if isCurrentMovie {
                Text("No credits available.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }
}

#Preview("Star Wars Detail") {
    MovieDetailView.previewDefault.withPreviewNavigation()
}

#Preview("Loading") {
    MovieDetailView.previewLoading.withPreviewNavigation()
}

#Preview("Error") {
    MovieDetailView.previewError.withPreviewNavigation()
}

#Preview("Empty Detail") {
    MovieDetailView.previewEmptyDetail.withPreviewNavigation()
}
