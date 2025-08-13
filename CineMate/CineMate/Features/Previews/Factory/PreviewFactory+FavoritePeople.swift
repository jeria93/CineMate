//
//  PreviewFactory+FavoritePeople.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-12.
//

import Foundation

/// Factory helpers for building `FavoritePeopleViewModel` instances
/// in known preview states (few/empty/many) without touching Firestore.
@MainActor
extension PreviewFactory {

    /// Core builder that injects mock favorites (bypasses `private(set)` via a preview helper).
    /// - Parameter people: The list to expose as current favorites.
    /// - Returns: A preconfigured `FavoritePeopleViewModel`.
    static func favoritePeopleVM(with people: [PersonRef]) -> FavoritePeopleViewModel {
        let vm = FavoritePeopleViewModel()
        vm._setPreviewFavorites(people)
        return vm
    }

    /// Ready-made: a small, realistic set of favorites.
    static func favoritePeopleDefaultVM() -> FavoritePeopleViewModel {
        favoritePeopleVM(with: FavoritePeoplePreviewData.few())
    }

    /// Ready-made: no favorites yet (empty state).
    static func favoritePeopleEmptyVM() -> FavoritePeopleViewModel {
        favoritePeopleVM(with: FavoritePeoplePreviewData.empty())
    }

    /// Ready-made: many favorites to test grid density and performance.
    static func favoritePeopleManyVM() -> FavoritePeopleViewModel {
        favoritePeopleVM(with: FavoritePeoplePreviewData.many())
    }
}
