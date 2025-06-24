//
//  MovieRowView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import SwiftUI

struct MovieRowView: View {
    let movie: Movie

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            PosterImageView(
                url: movie.posterSmallURL,
                title: movie.title,
                width: 80,
                height: 120
            )
            MovieRowDetails(
                movie: movie,
                spacing: 5,
                titleFont: .headline,
                overviewFont: .subheadline,
                showFullOverview: false
            )
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview("Default") {
    MovieRowView.previewDefault
}

#Preview("No poster") {
    MovieRowView.previewNoPoster
}

#Preview("No overview") {
    MovieRowView.previewNoOverview
}

#Preview("Long overview") {
    MovieRowView.previewLongOverview
}

#Preview("Minimal data") {
    MovieRowView.previewMinimalData
}
