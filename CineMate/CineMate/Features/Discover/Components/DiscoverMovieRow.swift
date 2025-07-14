//
//  DiscoverMovieRow.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-10.
//

import SwiftUI

struct DiscoverMovieRow: View {
    let movie: Movie

    @State private var isImageLoaded = false
    @State private var isTapped = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: movie.posterSmallURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 4)
                        .scaleEffect(isTapped ? 0.95 : (isImageLoaded ? 1 : 0.95))
                        .opacity(isImageLoaded ? 1 : 0)
                        .animation(.easeOut(duration: 0.3), value: isImageLoaded)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isTapped)
                        .onTapGesture {
                            isTapped = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isTapped = false
                            }
                        }
                        .onAppear {
                            isImageLoaded = true
                        }

                case .failure(_):
                    placeholderView

                case .empty:
                    placeholderView
                @unknown default:
                    placeholderView
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }

    private var placeholderView: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.gray.opacity(0.2))
            Image(systemName: "film")
                .font(.largeTitle)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(width: 80, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 1)
    }
}

#Preview("With Poster") {
    DiscoverMovieRow.previewPoster
}

#Preview("No Poster") {
    DiscoverMovieRow.previewNoPoster
}
