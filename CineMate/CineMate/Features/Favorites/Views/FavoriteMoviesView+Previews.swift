//
//  FavoriteMoviesView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import SwiftUI

extension FavoriteMoviesView {
    static var previewDefault: some View {
        FavoriteMoviesView(viewModel: PreviewFactory.favoriteMoviesViewModel())
    }
}
