//
//  PreviewFactory+Person.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-17.
//

import SwiftUI

/// Preview states for `PersonViewModel`.
/// These simulate common UI scenarios such as success, loading, error, and empty states.
@MainActor
extension PreviewFactory {

    /// Preview with full data for Mark Hamill (detail + movies).
    static var personViewModelPreview: PersonViewModel {
        resetAllPreviewData()
        let vm = PersonViewModel(repository: repository)
        vm.personDetail = PersonPreviewData.markHamill
        vm.personMovies = PersonPreviewData.movieCredits
        return vm
    }

    /// Preview simulating a loading state.
    static var personViewModelLoading: PersonViewModel {
        resetAllPreviewData()
        let vm = PersonViewModel(repository: repository)
        vm.isLoading = true
        return vm
    }

    /// Preview simulating an error state.
    static var personViewModelError: PersonViewModel {
        resetAllPreviewData()
        let vm = PersonViewModel(repository: repository)
        vm.errorMessage = "Unable to load person details."
        return vm
    }

    /// Preview with an empty/default state.
    static var personViewModelEmpty: PersonViewModel {
        resetAllPreviewData()
        return PersonViewModel(repository: repository)
    }
}
