//
//  PreviewFactory+CastViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

/// Previews for cast-related views and view models
@MainActor
extension PreviewFactory {

    /// Cast list with mock data
    static func castViewModel() -> CastViewModel {
        resetAllPreviewData()
        let vm = CastViewModel(repository: repository)
        vm.cast = MovieCreditsPreviewData.starWarsCredits().cast
        return vm
    }

    /// Cast member detail with mock data
    static func castMemberDetailView() -> some View {
        resetAllPreviewData()
        return NavigationStack {
            CastMemberDetailView(
                member: CastMemberPreviewData.markHamill,
                viewModel: .preview
            )
        }
    }
}
