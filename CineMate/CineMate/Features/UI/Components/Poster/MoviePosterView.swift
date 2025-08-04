//
//  MoviePosterView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import SwiftUI

struct MoviePosterView: View {
    let movie: Movie

    @State private var isImageLoaded = false
    @State private var isTapped = false
    @EnvironmentObject private var navigator: AppNavigator

    var body: some View {
        AsyncImage(url: movie.posterSmallURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 180)
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
                        navigator.goToMovie(id: movie.id)
                    }
                    .onAppear {
                        isImageLoaded = true
                    }

            case .failure(_):
                placeholder

            case .empty:
                placeholder

            @unknown default:
                placeholder
            }
        }
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
            Image(systemName: "film")
                .font(.largeTitle)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(width: 120, height: 180)
        .shadow(radius: 1)
    }
}

#Preview("Default") {
    MoviePosterView.previewDefault.withPreviewNavigation()
}

#Preview("Missing Poster") {
    MoviePosterView.previewMissingPoster.withPreviewNavigation()
}
