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
        HStack(alignment: .top, spacing: 16) {

            PosterImageView(url: movie.posterURL, title: movie.title)

//            Extrac? MovieRowDetails?
            VStack(alignment: .leading, spacing: 5) {

                Text(movie.title)
                    .font(.headline)

                if let overview = movie.overview {
                    Text(overview)
                        .font(.subheadline)
                        .lineLimit(3)
                        .foregroundColor(.secondary)
                }

                if let releaseDate = movie.realeaseDate {
                    Text("Release: \(releaseDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let voteAverage = movie.voteAverage {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)

                        Text(String(format: "%.1f", voteAverage))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
//    Create more previews on different scenarios?
    MovieRowView(movie: PreviewData.starWars)
}
// Skriv om hela sen, knappa allt från början
// Finns det fler scenarion tex, ej poster, eller ej title etc etc? skapa previews?
// skapa klart med list som gpt visade
// fråga, vad kan vi refaktorisera här? eller extrahera?
// Vad vill man visa upp i MovieRowView?
