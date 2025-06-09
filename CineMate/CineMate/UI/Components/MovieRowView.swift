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
            PosterImageView(url: movie.posterURL, title: movie.title)
            MovieRowDetails(movie: movie)
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    MovieRowView(movie: PreviewData.starWars)
}
