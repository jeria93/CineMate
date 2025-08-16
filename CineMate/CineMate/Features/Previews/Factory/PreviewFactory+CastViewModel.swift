//
//  PreviewFactory+CastViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

/// Previews for cast-related view models and views.
@MainActor
extension PreviewFactory {

    /// Cast list with mock data.
    static func castViewModel() -> CastViewModel {
        resetAllPreviewData()
        let vm = CastViewModel(repository: repository)
        vm.cast = MovieCreditsPreviewData.starWarsCredits().cast
        return vm
    }

    /// Cast member detail with mock data wrapped in a NavigationStack.
    static func castMemberDetailView() -> some View {
        resetAllPreviewData()
        let nav = AppNavigator()
        return NavigationStack {
            CastMemberDetailView(
                member: CastMemberPreviewData.markHamill,
                personViewModel: .preview,
                favoritePeopleVM: PreviewFactory.favoritePeopleDefaultVM()
            )
        }
        .environmentObject(nav)
    }
}
