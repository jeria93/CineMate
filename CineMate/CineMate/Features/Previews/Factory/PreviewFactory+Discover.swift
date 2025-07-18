//
//  PreviewFactory+Discover.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import SwiftUI

/// Preview factory for `DiscoverViewModel` simulating common UI states.
@MainActor
extension PreviewFactory {

    /// Fully populated DiscoverViewModel for default layout previews.
    static func discoverViewModel() -> DiscoverViewModel {
        resetAllPreviewData()
        return configuredViewModel {
            $0.results = SharedPreviewMovies.moviesList
            $0.topRatedMovies = SharedPreviewMovies.moviesList
            $0.popularMovies = SharedPreviewMovies.moviesList.shuffled()
            $0.nowPlayingMovies = SharedPreviewMovies.moviesList.reversed()
            $0.trendingMovies = SharedPreviewMovies.moviesList.shuffled()
            $0.upcomingMovies = SharedPreviewMovies.moviesList
            $0.horrorMovies = DiscoverHorrorPreviewData.horrorMovies
        }
    }

    /// Shows DiscoverViewModel in a loading state.
    static func loadingDiscoverViewModel() -> DiscoverViewModel {
        resetAllPreviewData()
        return configuredViewModel {
            $0.isLoading = true
        }
    }

    /// Empty state with no data loaded.
    static func emptyDiscoverViewModel() -> DiscoverViewModel {
        resetAllPreviewData()
        return configuredViewModel()
    }

    /// Error state with a custom message.
    static func errorDiscoverViewModel() -> DiscoverViewModel {
        resetAllPreviewData()
        return configuredViewModel {
            $0.error = .custom("Something went wrong")
        }
    }

    /// Only top-rated movies populated, useful for layout testing.
    static func oneSectionOnlyDiscoverViewModel() -> DiscoverViewModel {
        resetAllPreviewData()
        return configuredViewModel {
            $0.topRatedMovies = DiscoverPreviewData.movies
        }
    }

    /// Discover screen showing only horror movies.
    static func horrorOnlyDiscoverViewModel() -> DiscoverViewModel {
        resetAllPreviewData()
        return configuredViewModel {
            $0.horrorMovies = DiscoverHorrorPreviewData.horrorMovies
        }
    }

    /// Shared builder for consistent setup with mock repository.
    private static func configuredViewModel(_ configure: ((DiscoverViewModel) -> Void)? = nil) -> DiscoverViewModel {
        let viewModel = DiscoverViewModel(repository: MockMovieRepository())
        configure?(viewModel)
        return viewModel
    }
}
