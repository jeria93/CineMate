//
//  PreviewFactory+Discover.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import SwiftUI

/// Provides preconfigured `DiscoverViewModel` instances for SwiftUI previews.
/// Useful for previewing different UI states without triggering real network calls.
extension PreviewFactory {

    /// A complete DiscoverViewModel with mock movie results in all sections.
    @MainActor
    static func discoverViewModel() -> DiscoverViewModel {
        configuredViewModel {
            $0.results = DiscoverPreviewData.movies
            $0.topRatedMovies = DiscoverPreviewData.movies
            $0.popularMovies = DiscoverPreviewData.movies.shuffled()
            $0.nowPlayingMovies = DiscoverPreviewData.movies.reversed()
            $0.trendingMovies = DiscoverPreviewData.movies.shuffled()
        }
    }

    /// A DiscoverViewModel in loading state.
    @MainActor
    static func loadingDiscoverViewModel() -> DiscoverViewModel {
        configuredViewModel {
            $0.isLoading = true
        }
    }

    /// A DiscoverViewModel with empty results and sections.
    @MainActor
    static func emptyDiscoverViewModel() -> DiscoverViewModel {
        configuredViewModel()
    }

    /// A DiscoverViewModel simulating an error state.
    @MainActor
    static func errorDiscoverViewModel() -> DiscoverViewModel {
        configuredViewModel {
            $0.error = .custom("Something went wrong")
        }
    }

    /// A DiscoverViewModel with only one section populated.
    @MainActor
    static func oneSectionOnlyDiscoverViewModel() -> DiscoverViewModel {
        configuredViewModel {
            $0.topRatedMovies = DiscoverPreviewData.movies
        }
    }

    /// Base setup for any DiscoverViewModel with optional customization.
    @MainActor
    private static func configuredViewModel(_ configure: ((DiscoverViewModel) -> Void)? = nil) -> DiscoverViewModel {
        let viewModel = DiscoverViewModel(repository: MockMovieRepository())
        configure?(viewModel)
        return viewModel
    }
}
