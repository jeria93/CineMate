//
//  CastViewModel+Preview.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import Foundation

extension CastViewModel {
    static var preview: CastViewModel {
        let vm = CastViewModel(repository: PreviewFactory.repository)
        vm.cast = PreviewData.starWarsCredits().cast
        return vm
    }

    static var live: CastViewModel {
        CastViewModel(repository: MovieRepository())
    }
}


