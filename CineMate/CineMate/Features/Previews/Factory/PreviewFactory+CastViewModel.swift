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

    /// Cast view model with mock credits.
    static func castViewModel() -> CastViewModel {
        let vm = CastViewModel(repository: repository)
        vm.seedPreviewCredits(
            MovieCreditsPreviewData.starWarsCredits(movieId: SharedPreviewMovies.starWars.id)
        )
        return vm
    }

    /// Cast member detail preview in a navigation stack.
    static func castMemberDetailView() -> some View {
        let nav = AppNavigator()
        return NavigationStack {
            CastMemberDetailView(
                member: CastMemberPreviewData.markHamill,
                personViewModel: .preview,
                favoritePeopleVM: favoritePeopleDefaultVM(),
                movieViewModel: movieListViewModel()
            )
        }
        .environmentObject(nav)
    }
}
