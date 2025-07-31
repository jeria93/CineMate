//
//  PersonMovieCardView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

private extension MovieViewModel {
    /// Preview instance seeded with a single stub from the given credit.
    static func previewWithStub(from credit: PersonMovieCredit) -> MovieViewModel {
        let vm = MovieViewModel()
        if let stub = credit.asMovie {
            vm.cacheStub(stub)
        }
        return vm
    }
}

extension PersonMovieCardView {
    /// Preview with a full movie credit and stub injection so navigation detail has something immediately.
    static var preview: some View {
        let movieCredit = PersonMovieCardPreviewData.standard
        let movieVM = MovieViewModel.previewWithStub(from: movieCredit)

        return PersonMovieCardView(movie: movieCredit, movieViewModel: movieVM)
            .padding()
            .background(Color(.systemBackground))
            .withPreviewNavigation()
    }

    /// Preview where posterPath is missing (fallback image shown).
    static var previewMissingPoster: some View {
        let movieCredit = PersonMovieCardPreviewData.missingPoster
        let movieVM = MovieViewModel.previewWithStub(from: movieCredit)

        return PersonMovieCardView(movie: movieCredit, movieViewModel: movieVM)
            .padding()
            .background(Color(.systemBackground))
            .withPreviewNavigation()
    }

    /// Preview where title is nil (fallback "Untitled" shown).
    static var previewMissingTitle: some View {
        let movieCredit = PersonMovieCardPreviewData.missingTitle
        let movieVM = MovieViewModel.previewWithStub(from: movieCredit)

        return PersonMovieCardView(movie: movieCredit, movieViewModel: movieVM)
            .padding()
            .background(Color(.systemBackground))
            .withPreviewNavigation()
    }

    /// Variant without providing a MovieViewModel (no stub injection).
    static var previewWithoutStub: some View {
        PersonMovieCardView(movie: PersonMovieCardPreviewData.standard, movieViewModel: nil)
            .padding()
            .background(Color(.systemBackground))
            .withPreviewNavigation()
    }
}
