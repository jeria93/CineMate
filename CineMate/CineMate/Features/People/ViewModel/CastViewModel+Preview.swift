//
//  CastViewModel+Preview.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import Foundation

extension CastViewModel {
  static var preview: CastViewModel {
    PreviewID.reset()
    let vm = CastViewModel(repository: PreviewFactory.repository)
    vm.seedPreviewCredits(MovieCreditsPreviewData.starWarsCredits())
    return vm
  }

  static var live: CastViewModel {
    CastViewModel(repository: MovieRepository())
  }
}
