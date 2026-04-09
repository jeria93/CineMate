//
//  PreviewFactory+CastViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

/// Preview helpers for cast screens.
@MainActor
extension PreviewFactory {

    /// Cast view model with preview credits.
    static func castViewModel() -> CastViewModel {
        let vm = CastViewModel(repository: repository)
        vm.seedPreviewCredits(
            MovieCreditsPreviewData.starWarsCredits(movieId: SharedPreviewMovies.starWars.id)
        )
        return vm
    }

    /// Cast member detail preview.
    static func castMemberDetailView() -> some View {
        CastMemberDetailView(
            member: CastMemberPreviewData.markHamill,
            personViewModel: .preview,
            favoritePeopleVM: favoritePeopleDefaultVM(),
            movieViewModel: movieListViewModel()
        )
        .withPreviewNavigation()
    }
}
