//
//  TMDBLinkButtonView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-11.
//

import SwiftUI

struct TMDBLinkButtonView: View {
    let movie: Movie

    var body: some View {
        Link(destination: movie.tmdbURL) {
            Label("View on TMDB", systemImage: "link")
                .font(.caption)
                .fontWeight(.semibold)
                .padding(6)
                .foregroundColor(.accentColor)
                .background(Color.accentColor.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    TMDBLinkButtonView(movie: PreviewData.starWars)
}
