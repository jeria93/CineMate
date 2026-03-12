//
//  PreviewFactory+Person.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-17.
//

import SwiftUI

/// Preview states for `PersonViewModel`.
@MainActor
extension PreviewFactory {

  /// Full data preview.
  static var personViewModelPreview: PersonViewModel {
    resetAllPreviewData()
    let vm = PersonViewModel(repository: repository)
    vm.personDetail = PersonPreviewData.markHamill
    vm.personExternalIDs = PersonLinksPreviewData.markHamill
    vm.personMovies = PersonPreviewData.movieCredits
    return vm
  }

  /// Loading state preview.
  static var personViewModelLoading: PersonViewModel {
    resetAllPreviewData()
    let vm = PersonViewModel(repository: repository)
    vm.isLoading = true
    return vm
  }

  /// Error state preview.
  static var personViewModelError: PersonViewModel {
    resetAllPreviewData()
    let vm = PersonViewModel(repository: repository)
    vm.errorMessage = "Unable to load person details."
    return vm
  }

  /// Empty state preview.
  static var personViewModelEmpty: PersonViewModel {
    resetAllPreviewData()
    return PersonViewModel(repository: repository)
  }
}
