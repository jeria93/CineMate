//
//  RelatedMovieCardView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

extension RelatedMovieCardView {
    static var preview: some View {
        RelatedMovieCardView(movie: PreviewData.starWars)
            .padding()
            .background(Color(.systemBackground))
    }
}
