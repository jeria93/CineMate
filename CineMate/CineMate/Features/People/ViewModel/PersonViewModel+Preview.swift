//
//  PersonViewModel+Preview.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import Foundation

extension PersonViewModel {
    static var preview: PersonViewModel {
        let vm = PersonViewModel(repository: PreviewFactory.repository)
        vm.personDetail = PreviewData.markHamillPersonDetail
        vm.personMovies = PreviewData.markHamillMovieCredits
        return vm
    }

    static var loading: PersonViewModel {
        let vm = PersonViewModel(repository: PreviewFactory.repository)
        vm.isLoading = true
        return vm
    }

    static var error: PersonViewModel {
        let vm = PersonViewModel(repository: PreviewFactory.repository)
        vm.errorMessage = "Unable to load person details."
        return vm
    }

    static var empty: PersonViewModel {
        PersonViewModel(repository: PreviewFactory.repository)
    }
}
