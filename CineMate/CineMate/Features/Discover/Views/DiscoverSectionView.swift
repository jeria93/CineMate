//
//  DiscoverSectionView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-10.
//

import SwiftUI

struct DiscoverSectionView: View {
    let title: String
    let movies: [Movie]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2.bold())
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(movies) { movie in
                        DiscoverMovieRow(movie: movie)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
}

#Preview("Default") {
    DiscoverSectionView.previewDefault
}

#Preview("Empty") {
    DiscoverSectionView.previewEmpty
}

#Preview("One Movie") {
    DiscoverSectionView.previewOneMovie
}

#Preview("No Posters") {
    DiscoverSectionView.previewNoPosters
}
