//
//  DiscoverSectionView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-10.
//

import SwiftUI

struct DiscoverSectionView: View {
    let title: String
    let movies: [Movie]
    let onSeeAllTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTextPrimary)

                Spacer()

                Button("See all", action: onSeeAllTap)
                    .font(.subheadline.weight(.semibold))
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.appPrimaryAction)
            }
            .padding(.horizontal)

            if !movies.isEmpty {
                SectionMoviesView(movies: movies)
            } else {
                EmptyStateView(
                    systemImage: "film",
                    title: "No movies",
                    message: "This section is empty right now.",
                    layout: .inline
                )
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .padding(.top)
    }
}

#Preview("Default") {
    DiscoverSectionView.previewDefault.withPreviewNavigation()
}

#Preview("Empty") {
    DiscoverSectionView.previewEmpty.withPreviewNavigation()
}

#Preview("One Movie") {
    DiscoverSectionView.previewOneMovie.withPreviewNavigation()
}

#Preview("No Posters") {
    DiscoverSectionView.previewNoPosters.withPreviewNavigation()
}
