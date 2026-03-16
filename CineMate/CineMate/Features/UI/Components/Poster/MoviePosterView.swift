//
//  MoviePosterView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import SwiftUI

struct MoviePosterView: View {
    let movie: Movie
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    @EnvironmentObject private var navigator: AppNavigator

    init(
        movie: Movie,
        width: CGFloat = SharedUI.Size.posterGrid.width,
        height: CGFloat = SharedUI.Size.posterGrid.height,
        cornerRadius: CGFloat = SharedUI.Radius.medium,
        shadowRadius: CGFloat = 4
    ) {
        self.movie = movie
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }

    var body: some View {
        PosterImageView(
            url: movie.posterSmallURL,
            title: movie.title,
            width: width,
            height: height,
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius,
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
