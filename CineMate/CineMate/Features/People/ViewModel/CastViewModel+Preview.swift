//
//  CastViewModel+Preview.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import Foundation

extension CastViewModel {
    static var preview: CastViewModel {
        PreviewFactory.castViewModel()
    }

    static var live: CastViewModel {
        CastViewModel(repository: MovieRepository())
    }
}
