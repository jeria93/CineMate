//
//  DiscoverContentView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-12.
//

import SwiftUI

/// Displays the Discover screen content:
/// - Horizontal genre selector (auto-scrolls to selected genre)
/// - Movie sections (Top Rated, Trending, etc.)
/// - Scrolls to top automatically when genre changes.
struct DiscoverContentView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @State private var lastSelectedGenreId: Int? = nil

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 24, pinnedViews: []) {
                    // Genre selector
                    GenreSelectorView(
                        genres: viewModel.genres,
                        selectedGenreId: viewModel.selectedGenreId
                    ) { selected in
                        viewModel.selectedGenreId = selected
                    }
                    .id("genreSelector") // For scroll-to-top

                    // Sections
                    sectionView(title: "Top Rated", movies: viewModel.topRatedMovies)
                    sectionView(title: "Trending", movies: viewModel.trendingMovies)
                    sectionView(title: "Now Playing", movies: viewModel.nowPlayingMovies)
                    sectionView(title: "Upcoming", movies: viewModel.upcomingMovies)
                    sectionView(title: "Horror", movies: viewModel.horrorMovies)
                }
                .padding(.vertical)
            }
            // Auto scroll-to-top when selected genre changes
            .onChange(of: viewModel.selectedGenreId) { _, newValue in
                guard lastSelectedGenreId != newValue else { return }
                lastSelectedGenreId = newValue
                scrollToTop(proxy: proxy)
            }
        }
    }

    /// Scrolls the main ScrollView to top with animation
    private func scrollToTop(proxy: ScrollViewProxy) {
        withAnimation(.easeInOut(duration: 0.3)) {
            proxy.scrollTo("genreSelector", anchor: .top)
        }
    }

    /// Generates a DiscoverSectionView only if movies are available
    @ViewBuilder
    private func sectionView(title: String, movies: [Movie]) -> some View {
        if !movies.isEmpty {
            DiscoverSectionView(title: title, movies: movies)
        }
    }
}

#Preview("Default") {
    DiscoverContentView.previewDefault
}
