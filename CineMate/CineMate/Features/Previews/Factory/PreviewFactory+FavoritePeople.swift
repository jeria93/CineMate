//
//  PreviewFactory+FavoritePeople.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-12.
//

import Foundation

/// Factory helpers for `FavoritePeopleViewModel` preview states.
/// Uses the VM's static mode – never touches Firestore.
@MainActor
extension PreviewFactory {

    /// Core builder – seeds the VM with a fixed list.
    /// - Parameter people: People to expose in the UI.
    static func favoritePeopleVM(with people: [PersonRef]) -> FavoritePeopleViewModel {
        FavoritePeopleViewModel(preview: people)
    }

    /// Default scenario: a small, human-readable set.
    static func favoritePeopleDefaultVM() -> FavoritePeopleViewModel {
        favoritePeopleVM(with: FavoritePeoplePreviewData.few())
    }

    /// Empty scenario: no favorite people.
    static func favoritePeopleEmptyVM() -> FavoritePeopleViewModel {
        favoritePeopleVM(with: FavoritePeoplePreviewData.empty())
    }

    /// Many scenario: grid/scroll density checks.
    static func favoritePeopleManyVM() -> FavoritePeopleViewModel {
        favoritePeopleVM(with: FavoritePeoplePreviewData.many())
    }
}
