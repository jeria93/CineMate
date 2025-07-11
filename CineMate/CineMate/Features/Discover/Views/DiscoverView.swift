//
//  DiscoverView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel: DiscoverViewModel
    
    init(viewModel: DiscoverViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView("Loading...")
                        Spacer()
                    }
                } else if let error = viewModel.error {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text("Something went wrong")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                } else if viewModel.allSectionsAreEmpty {
                    Text("No movies to show.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            DiscoverSectionView(title: "Top Rated", movies: viewModel.topRatedMovies)
                            DiscoverSectionView(title: "Popular", movies: viewModel.popularMovies)
                            DiscoverSectionView(title: "Now Playing", movies: viewModel.nowPlayingMovies)
                            DiscoverSectionView(title: "Trending", movies: viewModel.trendingMovies)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Discover")
            .task {
                guard !ProcessInfo.processInfo.isPreview else { return }
                await viewModel.fetchAllSections()
            }
        }
    }
}

#Preview("Default") {
    DiscoverView.previewDefault
}

#Preview("Loading") {
    DiscoverView.previewLoading
}

#Preview("Empty") {
    DiscoverView.previewEmpty
}

#Preview("Error") {
    DiscoverView.previewError
}

#Preview("One Section") {
    DiscoverView.previewOneSection
}
