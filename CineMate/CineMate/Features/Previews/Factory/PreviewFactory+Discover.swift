//
//  PreviewFactory+Discover.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import SwiftUI

/// Provides preconfigured DiscoverViewModel instances for SwiftUI previews.
/// Used to simulate different UI states without triggering real API calls.
extension PreviewFactory {

    /// ViewModel with all sections populated for default layout previews.
    @MainActor
    static func discoverViewModel() -> DiscoverViewModel {
        configuredViewModel {
            $0.results = SharedPreviewMovies.moviesList
            $0.topRatedMovies = SharedPreviewMovies.moviesList
            $0.popularMovies = SharedPreviewMovies.moviesList.shuffled()
            $0.nowPlayingMovies = SharedPreviewMovies.moviesList.reversed()
            $0.trendingMovies = SharedPreviewMovies.moviesList.shuffled()
            $0.upcomingMovies = SharedPreviewMovies.moviesList
            $0.horrorMovies = DiscoverHorrorPreviewData.horrorMovies
        }
    }

    /// ViewModel simulating loading state for shimmer/spinner previews.
    @MainActor
    static func loadingDiscoverViewModel() -> DiscoverViewModel {
        configuredViewModel {
            $0.isLoading = true
        }
    }

    /// ViewModel with no data loaded (empty screen preview).
    @MainActor
    static func emptyDiscoverViewModel() -> DiscoverViewModel {
        configuredViewModel()
    }

    /// ViewModel with a simulated error message.
    @MainActor
    static func errorDiscoverViewModel() -> DiscoverViewModel {
        configuredViewModel {
            $0.error = .custom("Something went wrong")
        }
    }

    /// ViewModel with a single populated section for minimal previews.
    @MainActor
    static func oneSectionOnlyDiscoverViewModel() -> DiscoverViewModel {
        configuredViewModel {
            $0.topRatedMovies = DiscoverPreviewData.movies
        }
    }

    /// ViewModel showing only horror movies.
    @MainActor
    static func horrorOnlyDiscoverViewModel() -> DiscoverViewModel {
        configuredViewModel {
            $0.horrorMovies = DiscoverHorrorPreviewData.horrorMovies
        }
    }

    /// Shared builder for consistent setup with mock repository.
    @MainActor
    private static func configuredViewModel(_ configure: ((DiscoverViewModel) -> Void)? = nil) -> DiscoverViewModel {
        let viewModel = DiscoverViewModel(repository: MockMovieRepository())
        configure?(viewModel)
        return viewModel
    }
}
