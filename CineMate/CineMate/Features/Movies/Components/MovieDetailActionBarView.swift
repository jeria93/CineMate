//
//  MovieDetailActionBarView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-13.
//

import SwiftUI

struct MovieDetailActionBarView: View {
    let movie: Movie
    @Environment(\.openURL) var openURL
    @State private var shareItem: MovieShareItem?

    var body: some View {

        HStack(spacing: 12) {
            Button {
                let url = TrailerHelper.bestAvailableURL(for: movie)
                openURL(url)
            } label: {
                Label("Trailer", systemImage: "play.rectangle.fill")
                    .actionButtonStyle(.red)
            }

            if let shareItem {
                ShareLink(item: shareItem.url, preview: SharePreview(shareItem.title, image: Image(uiImage: shareItem.image))) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .actionButtonStyle(.accentColor)
                }
            } else {
                ProgressView()
                    .frame(width: 24, height: 24)
                    .onAppear {
                        Task {
                            shareItem = await ShareHelper.createShareItem(for: movie)
                        }
                    }
            }

            Link(destination: movie.tmdbURL) {
                Label("TMDB", systemImage: "link")
                    .actionButtonStyle(.blue)
            }
        }
        .padding(.top, 8)
    }
}

#Preview {
    MovieDetailActionBarView.previewDefault

}

private extension Label where Title == Text, Icon == Image {
    func actionButtonStyle(_ color: Color) -> some View {
        self
            .frame(width: 90, height: 15)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(6)
            .foregroundStyle(.white)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
