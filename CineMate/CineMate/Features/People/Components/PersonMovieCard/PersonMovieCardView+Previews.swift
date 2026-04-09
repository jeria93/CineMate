//
//  PersonMovieCardView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

private extension MovieViewModel {
    /// Preview model with one cached movie stub.
    static func previewWithStub(from credit: PersonMovieCredit) -> MovieViewModel {
        let vm = MovieViewModel(repository: PreviewFactory.repository)
        if let stub = credit.asMovie {
            vm.cacheStub(stub)
        }
        return vm
    }
}

extension PersonMovieCardView {
    /// Full preview state.
    static var preview: some View {
        let movieCredit = PersonMovieCardPreviewData.standard
        let movieVM = MovieViewModel.previewWithStub(from: movieCredit)
        
        return PersonMovieCardView(movie: movieCredit, movieViewModel: movieVM)
            .padding()
            .background(Color(.systemBackground))
            .withPreviewNavigation()
    }
    
    /// Missing poster state.
    static var previewMissingPoster: some View {
        let movieCredit = PersonMovieCardPreviewData.missingPoster
        let movieVM = MovieViewModel.previewWithStub(from: movieCredit)
        
        return PersonMovieCardView(movie: movieCredit, movieViewModel: movieVM)
            .padding()
            .background(Color(.systemBackground))
            .withPreviewNavigation()
    }
    
    /// Missing title state.
    static var previewMissingTitle: some View {
        let movieCredit = PersonMovieCardPreviewData.missingTitle
        let movieVM = MovieViewModel.previewWithStub(from: movieCredit)
        
        return PersonMovieCardView(movie: movieCredit, movieViewModel: movieVM)
            .padding()
            .background(Color(.systemBackground))
            .withPreviewNavigation()
    }
    
    /// Preview without a movie stub.
    static var previewWithoutStub: some View {
        PersonMovieCardView(movie: PersonMovieCardPreviewData.standard, movieViewModel: nil)
            .padding()
            .background(Color(.systemBackground))
            .withPreviewNavigation()
    }
}
