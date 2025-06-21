//
//  PersonViewModel+Preview.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import Foundation

extension PersonViewModel {
    static var preview: PersonViewModel {
        let vm = PersonViewModel(repository: MockMovieRepository())
        vm.personDetail = PreviewData.markHamillPersonDetail
        return vm
    }
}
