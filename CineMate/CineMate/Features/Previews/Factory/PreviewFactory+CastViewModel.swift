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
    resetAllPreviewData()
    let vm = CastViewModel(repository: repository)
    vm.seedPreviewCredits(MovieCreditsPreviewData.starWarsCredits())
    return vm
  }

  /// Cast member detail preview in a navigation stack.
  static func castMemberDetailView() -> some View {
    resetAllPreviewData()
    let nav = AppNavigator()
    return NavigationStack {
      CastMemberDetailView(
        member: CastMemberPreviewData.markHamill,
        personViewModel: .preview,
        favoritePeopleVM: PreviewFactory.favoritePeopleDefaultVM(),
        movieViewModel: PreviewFactory.movieListViewModel()
      )
    }
    .environmentObject(nav)
  }
}
