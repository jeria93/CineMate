//
//  MovieDetailActionBarView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

extension MovieDetailActionBarView {

    static var preview: some View {
        PreviewID.reset()
        return MovieDetailActionBarView(movie: SharedPreviewMovies.starWars)
            .padding()
            .background(Color(.systemBackground))
    }
}
