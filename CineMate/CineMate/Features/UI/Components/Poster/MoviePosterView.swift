//
//  MoviePosterView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import SwiftUI

/// Wraps PosterImageView with movie detail navigation and a grid poster style by default.
struct MoviePosterView: View {
    let movie: Movie
    var configuration: PosterImageConfiguration = .grid
    @EnvironmentObject private var navigator: AppNavigator

    var body: some View {
        PosterImageView(
            url: movie.posterSmallURL,
            title: movie.title,
            configuration: configuration,
            onTap: { navigator.goToMovie(id: movie.id) }
        )
    }
}

#Preview("Default") {
    MoviePosterView.previewDefault.withPreviewNavigation()
}

#Preview("Missing Poster") {
    MoviePosterView.previewMissingPoster.withPreviewNavigation()
}
