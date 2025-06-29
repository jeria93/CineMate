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
    let instagramURL: URL?
    let twitterURL: URL?
    let facebookURL: URL?

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                if let imdbURL {
                    Link(destination: imdbURL) {
                        Label("IMDb", systemImage: "film.fill")
                    }
                }

                if let tmdbURL {
                    Link(destination: tmdbURL) {
                        Label("TMDB", systemImage: "sparkles.tv")
                    }

                    ShareLink(item: tmdbURL) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }

            HStack(spacing: 16) {
                if let instagramURL {
                    Link(destination: instagramURL) {
                        Label("Instagram", systemImage: "camera")
                    }
                }

                if let twitterURL {
                    Link(destination: twitterURL) {
                        Label("Twitter", systemImage: "bird")
                    }
                }

                if let facebookURL {
                    Link(destination: facebookURL) {
                        Label("Facebook", systemImage: "person.2.fill")
                    }
                }
            }
        }
        .labelStyle(.iconOnly)
        .font(.headline)
    }
}

#Preview("Social Media Links") {
    PersonLinksView.preview
}
