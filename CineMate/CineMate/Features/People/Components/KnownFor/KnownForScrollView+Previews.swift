//
//  KnownForScrollView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

private extension MovieViewModel {
    /// Preview instance seeded with stubs from person’s known-for credits.
    static var previewWithStubs: MovieViewModel {
        let vm = MovieViewModel()
        for credit in PersonPreviewData.movieCredits {
            if let stub = credit.asMovie {
                vm.cacheStub(stub)
            }
        }
        return vm
    }
}

extension KnownForScrollView {
    static var previewFull: some View {
        let movieVM = MovieViewModel.previewWithStubs
        return KnownForScrollView(
            movies: PersonPreviewData.movieCredits,
            movieViewModel: movieVM
        )
        .padding()
        .background(Color(.systemBackground))
        .withPreviewNavigation()
    }

    static var previewEmpty: some View {
        KnownForScrollView(
            movies: [],
            movieViewModel: nil
        )
        .padding()
        .background(Color(.systemBackground))
        .withPreviewNavigation()
    }

    static var previewPartial: some View {
        let partial = [
            PersonMovieCredit(
                id: PreviewID.scoped(.peopleComponents, 20),
                title: "Mysterious Adventure",
                character: nil,
                releaseDate: "2025-01-01",
                posterPath: nil,
                popularity: nil
            )
        ]
        let movieVM = MovieViewModel.previewWithStubs
        return KnownForScrollView(
            movies: partial,
            movieViewModel: movieVM
        )
        .padding()
        .background(Color(.systemBackground))
        .withPreviewNavigation()
    }

    static var previewOverflow: some View {
        let manyMovies = (1...25).map { index in
            PersonMovieCredit(
                id: PreviewID.scoped(.peopleComponents, 100 + index),
                title: "Movie \(index)",
                character: nil,
                releaseDate: "20\(10 + index)-01-01",
                posterPath: nil,
                popularity: Double(100 - index)
            )
        }
        let movieVM = MovieViewModel.previewWithStubs
        return KnownForScrollView(
            movies: manyMovies,
            movieViewModel: movieVM
        )
        .padding()
        .background(Color(.systemBackground))
        .withPreviewNavigation()
    }
}
