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
            } else {
                Text("No director info.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            if !credits.cast.isEmpty {
                let castNames = credits.cast.prefix(3).map(\.name).joined(separator: ", ")
                Text("Starring: \(castNames)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("No cast info.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview("Star Wars Credits") {
    MovieCreditsView.previewStarWars
}

#Preview("Empty Credits (Fallback)") {
    MovieCreditsView.previewEmptyCredits
}

#Preview("Only Director") {
    MovieCreditsView.previewOnlyDirector
}

#Preview("Only Cast") {
    MovieCreditsView.previewOnlyCast
}
