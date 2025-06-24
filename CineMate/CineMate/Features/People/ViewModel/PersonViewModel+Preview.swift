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
        vm.personMovies = PreviewData.markHamillMovies
        return vm
    }

    static var live: PersonViewModel {
        PersonViewModel(repository: MovieRepository())
    }
}
