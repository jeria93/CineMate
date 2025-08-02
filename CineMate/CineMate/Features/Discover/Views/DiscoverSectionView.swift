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
    @EnvironmentObject private var navigator: AppNavigator

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2.bold())
                .padding(.horizontal)
                .onTapGesture {
                    navigator.goToSeeAllMovies(title: title, filter: DiscoverFilterProvider.filter(for: title))
                }

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
    DiscoverSectionView.previewDefault.withPreviewNavigation()
}

#Preview("Empty") {
    DiscoverSectionView.previewEmpty.withPreviewNavigation()
}

#Preview("One Movie") {
    DiscoverSectionView.previewOneMovie.withPreviewNavigation()
}

#Preview("No Posters") {
    DiscoverSectionView.previewNoPosters.withPreviewNavigation()
}
