//
//  DiscoverContentView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-12.
//

import SwiftUI

struct DiscoverContentView: View {
    let viewModel: DiscoverViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                GenreSelectorView(
                    genres: viewModel.genres,
                    selectedGenreId: viewModel.selectedGenreId
                ) { selected in
                    viewModel.selectedGenreId = selected.id
                }

                if !viewModel.topRatedMovies.isEmpty {
                    DiscoverSectionView(title: "Top Rated", movies: viewModel.topRatedMovies)
                }

                if !viewModel.popularMovies.isEmpty {
                    DiscoverSectionView(title: "Popular", movies: viewModel.popularMovies)
                }

                if !viewModel.trendingMovies.isEmpty {
                    DiscoverSectionView(title: "Trending", movies: viewModel.trendingMovies)
                }

                if !viewModel.nowPlayingMovies.isEmpty {
                    DiscoverSectionView(title: "Now Playing", movies: viewModel.nowPlayingMovies)
                }

                if !viewModel.upcomingMovies.isEmpty {
                    DiscoverSectionView(title: "Upcoming", movies: viewModel.upcomingMovies)
                }

                if !viewModel.horrorMovies.isEmpty {
                    DiscoverSectionView(title: "Horror", movies: viewModel.horrorMovies)
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            guard !ProcessInfo.processInfo.isPreview else { return }
            await viewModel.fetchAllSections()
        }
    }
}

#Preview("Default") {
    DiscoverContentView.previewDefault
}

#Preview("Horror Only") {
    DiscoverContentView.previewHorrorOnly
}
