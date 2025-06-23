//
//  MovieCreditsView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-11.
//

import SwiftUI

struct MovieCreditsView: View {
    let credits: MovieCredits

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let director = credits.crew.first(where: { $0.job == "Director" })?.name {
                Text("Directed by: \(director)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if !credits.cast.isEmpty {
                Text("Starring: \(credits.cast.prefix(3).map(\.name).joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    MovieCreditsView.previewStarWars
}
