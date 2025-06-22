//
//  PersonLinksView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-22.
//

import SwiftUI

struct PersonLinksView: View {
    let imdbURL: URL?
    let tmdbURL: URL?

    var body: some View {
        HStack(spacing: 16) {
            if let imdbURL {
                Link(destination: imdbURL) {
                    Label("IMDb", systemImage: "film.fill")
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.yellow.opacity(0.15))
                        .foregroundStyle(Color.yellow)
                        .cornerRadius(12)
                        .shadow(color: .yellow.opacity(0.2), radius: 4, x: 0, y: 2)
                }
            }

            if let tmdbURL {
                Link(destination: tmdbURL) {
                    Label("TMDB", systemImage: "sparkles.tv")
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.15))
                        .foregroundStyle(Color.blue)
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.2), radius: 4, x: 0, y: 2)
                }

                ShareLink(item: tmdbURL) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.15))
                        .foregroundStyle(Color.primary)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                }
            }
        }
        .padding(.top)
    }
}
#Preview("Links – Mark Hamill") {
    PersonLinksView(
        imdbURL: PreviewData.markHamillPersonDetail.imdbURL,
        tmdbURL: PreviewData.markHamillPersonDetail.tmdbURL
    )
}
