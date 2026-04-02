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
    @EnvironmentObject private var navigator: AppNavigator
    @State private var lastSelectedGenreId: Int?

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
                    ForEach(viewModel.visibleSections) { section in
                        DiscoverSectionView(
                            title: section.title,
                            movies: section.movies,
                            onSeeAllTap: {
                                navigator.goToSeeAllMovies(
                                    title: section.title,
                                    source: viewModel.seeAllSource(for: section.kind)
                                )
                            }
                        )
                    }
                }
                .padding(.vertical)
            }
            .background(Color.appBackground)
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
}

#Preview("Default") {
    DiscoverContentView.previewDefault
}
