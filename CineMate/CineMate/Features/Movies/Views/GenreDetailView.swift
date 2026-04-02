//
//  GenreDetailView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-30.
//

import SwiftUI

struct GenreDetailView: View {
    let genreId: Int
    let genreName: String
    @StateObject private var viewModel: GenreDetailViewModel
    
    private enum ScrollAnchor {
        static let allMovies = "allGenreMovies"
    }
    
    init(
        genreId: Int,
        genreName: String,
        repository: MovieProtocol = MovieRepository()
    ) {
        self.genreId = genreId
        self.genreName = genreName
        _viewModel = StateObject(
            wrappedValue: GenreDetailViewModel(genreId: genreId, repository: repository)
        )
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.hasNoContent {
                LoadingView(title: "Loading \(genreName)...")
            } else if viewModel.hasNoContent, let errorMessage = viewModel.primaryErrorMessage {
                ErrorMessageView(
                    title: "Could not load \(genreName)",
                    message: errorMessage,
                    onRetry: { Task { await viewModel.refresh() } }
                )
            } else {
                content
            }
        }
        .navigationTitle(genreName)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.appBackground.ignoresSafeArea())
        .task(id: genreId) {
            await viewModel.loadIfNeeded()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    private var content: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    headerCard
                    
                    if !viewModel.popularMovies.isEmpty {
                        DiscoverSectionView(
                            title: "Popular in \(genreName)",
                            movies: viewModel.popularMovies,
                            onSeeAllTap: { scrollToAllMovies(using: proxy) }
                        )
                    }
                    
                    if !viewModel.topRatedMovies.isEmpty {
                        DiscoverSectionView(
                            title: "Top Rated \(genreName)",
                            movies: viewModel.topRatedMovies,
                            onSeeAllTap: { scrollToAllMovies(using: proxy) }
                        )
                    }
                    
                    if !viewModel.newReleaseMovies.isEmpty {
                        DiscoverSectionView(
                            title: "New Releases",
                            movies: viewModel.newReleaseMovies,
                            onSeeAllTap: { scrollToAllMovies(using: proxy) }
                        )
                    }
                    
                    allMoviesSection
                        .id(ScrollAnchor.allMovies)
                }
                .padding(.vertical)
            }
            .background(Color.appBackground)
        }
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(genreName)
                .font(.title.bold())
                .foregroundStyle(Color.appTextPrimary)
            
            Text("Explore highlights and browse the full catalog in one place.")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(16)
        .background(Color.appSurface)
        .overlay(
            RoundedRectangle(cornerRadius: SharedUI.Radius.large, style: .continuous)
                .stroke(Color.appTextSecondary.opacity(0.16), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: SharedUI.Radius.large, style: .continuous))
        .padding(.horizontal)
    }
    
    private var allMoviesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text("All \(genreName)")
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTextPrimary)
                
                Spacer()
                
                Picker("Sort", selection: $viewModel.selectedSort) {
                    ForEach(GenreDetailViewModel.AllMoviesSort.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .tint(.appPrimaryAction)
            }
            .padding(.horizontal)
            
            if viewModel.allMovies.isEmpty, viewModel.isLoadingMore {
                ProgressView("Loading movies...")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            } else if viewModel.allMovies.isEmpty {
                EmptyStateView(
                    systemImage: "film.stack",
                    title: "No movies found",
                    message: "Try another sort option or refresh.",
                    layout: .inline
                )
                .padding(.horizontal)
            } else {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
                    spacing: 16
                ) {
                    ForEach(viewModel.allMovies) { movie in
                        MoviePosterView(movie: movie)
                            .onAppear {
                                Task {
                                    await viewModel.loadNextPageIfNeeded(currentItem: movie)
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
            
            if viewModel.isLoadingMore, !viewModel.allMovies.isEmpty {
                ProgressView()
                    .tint(.appPrimaryAction)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            
            if let listErrorMessage = viewModel.listErrorMessage {
                HStack(spacing: 10) {
                    Text(listErrorMessage)
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Button("Retry") {
                        Task { await viewModel.retryAllMovies() }
                    }
                    .buttonStyle(.bordered)
                    .tint(.appPrimaryAction)
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func scrollToAllMovies(using proxy: ScrollViewProxy) {
        withAnimation(.easeInOut(duration: 0.25)) {
            proxy.scrollTo(ScrollAnchor.allMovies, anchor: .top)
        }
    }
}

#Preview {
    GenreDetailView(
        genreId: 28,
        genreName: "Action",
        repository: MockMovieRepository()
    )
    .withPreviewNavigation()
}
