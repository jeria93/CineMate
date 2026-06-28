//
//  MovieCreditsSection.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-06-27.
//

import SwiftUI

/// Shows credits for the active movie while avoiding stale cast data during navigation.
struct MovieCreditsSection: View {
    let movieId: Int
    @ObservedObject var castViewModel: CastViewModel
    let onRetry: () -> Void

    private var isCurrentMovie: Bool {
        castViewModel.activeMovieID == movieId
    }

    private var currentCredits: MovieCredits? {
        guard isCurrentMovie else { return nil }
        return castViewModel.credits
    }

    private var hasAnyCredits: Bool {
        guard let currentCredits else { return false }
        return !currentCredits.cast.isEmpty || !currentCredits.crew.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if castViewModel.isLoading, currentCredits == nil {
                ProgressView("Loading credits…")
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if let errorMessage = castViewModel.errorMessage, currentCredits == nil, isCurrentMovie {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Could not load credits")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                    Button("Retry Credits", action: onRetry)
                        .buttonStyle(.bordered)
                        .tint(.appPrimaryAction)
                }
            } else if hasAnyCredits, let currentCredits {
                MovieCreditsView(credits: currentCredits)
                if let director = currentCredits.crew.first(where: { $0.job == "Director" }) {
                    DirectorView(director: director)
                }
                CastCarouselView(cast: currentCredits.cast)
            } else if isCurrentMovie {
                Text("No credits available.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }
}
