//
//  CastViewModel+Preview.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import Foundation

extension CastViewModel {
    static var preview: CastViewModel {
        let vm = CastViewModel(repository: MockMovieRepository())
        vm.cast = PreviewData.starWarsCredits.cast
        vm.crew = PreviewData.starWarsCredits.crew
        return vm
    }
}


