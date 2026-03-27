//
//  MovieDetailActionBarView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-13.
//

import SwiftUI

struct MovieDetailActionBarView: View {
    let movie: Movie
    let videos: [MovieVideo]

    @Environment(\.openURL) var openURL
    @State private var shareItem: MovieShareItem?
    @State private var isPreparingShareItem = false

    var body: some View {
        HStack(spacing: 12) {
            Button {
                let url = TrailerHelper.bestAvailableURL(for: movie, videos: videos)
                openURL(url)
            } label: {
                Label("Trailer", systemImage: "play.rectangle.fill")
                    .actionButtonStyle(background: .appPrimaryAction, foreground: .tmdbNavy)
            }

            shareButton

            Link(destination: movie.tmdbURL) {
                Label("TMDB", systemImage: "link")
                    .actionButtonStyle(background: .tmdbNavy, foreground: .white)
            }
        }
        .padding(.top, 8)
        .task(id: movie.id) {
            await prepareShareItem()
        }
    }

    @ViewBuilder
    private var shareButton: some View {
        if let shareItem {
            ShareLink(
                item: shareItem.url,
                preview: SharePreview(shareItem.title, image: Image(uiImage: shareItem.image))
            ) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .actionButtonStyle(background: .tmdbGreen, foreground: .tmdbNavy)
            }
        } else {
            ShareLink(item: movie.tmdbURL) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .actionButtonStyle(background: .tmdbGreen, foreground: .tmdbNavy)
                    .opacity(isPreparingShareItem ? 0.75 : 1)
            }
            .overlay(alignment: .trailing) {
                if isPreparingShareItem {
                    ProgressView()
                        .controlSize(.mini)
                        .tint(Color.tmdbNavy)
                        .padding(.trailing, 8)
                }
            }
        }
    }

    private func prepareShareItem() async {
        isPreparingShareItem = true
        shareItem = nil
        shareItem = await ShareHelper.createShareItem(for: movie)
        isPreparingShareItem = false
    }
}

#Preview {
    MovieDetailActionBarView.previewDefault
}

extension Label where Title == Text, Icon == Image {
    fileprivate func actionButtonStyle(background: Color, foreground: Color) -> some View {
        self
            .frame(width: 90, height: 15)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(6)
            .foregroundStyle(foreground)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
