//
//  MovieDetailInfoView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-10.
//

import SwiftUI

struct MovieDetailInfoView: View {
    let movie: Movie
    let detail: MovieDetail?
    let watchProviderRegion: WatchProviderRegion?
    let isLoading: Bool

    @EnvironmentObject private var navigator: AppNavigator

    private var titleText: String {
        detail?.title ?? movie.title
    }

    private var releaseDateText: String? {
        detail?.releaseDate ?? movie.releaseDate
    }

    private var voteAverageValue: Double? {
        detail?.voteAverage ?? movie.voteAverage
    }

    private var overviewText: String? {
        detail?.overview ?? movie.overview
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(titleText)
                .font(.largeTitle.bold())

            HStack(spacing: 10) {
                if let releaseDateText {
                    Text("Release: \(releaseDateText)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let voteAverageValue {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", voteAverageValue))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            if let genres = detail?.genres, !genres.isEmpty {
                MovieGenresView(genres: genres)
                    .environmentObject(navigator)
            }

            if let overviewText, !overviewText.isEmpty {
                Text(overviewText)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            if let watchProviderRegion {
                WatchProvidersView(region: watchProviderRegion)
            }

            if let detail {
                detailMetadata(detail)
            } else if isLoading {
                ProgressView("Loading movie details...")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private func detailMetadata(_ detail: MovieDetail) -> some View {
        Divider()

        if let runtime = detail.runtime {
            Text("Runtime: \(runtime / 60)h \(runtime % 60)m")
                .font(.caption)
                .foregroundColor(.secondary)
        }

        if !detail.productionCompanies.isEmpty {
            Text("Produced by: \(detail.productionCompanies.map { $0.name }.joined(separator: ", "))")
                .font(.caption)
                .foregroundColor(.secondary)
        }

        if !detail.productionCountries.isEmpty {
            Text("Countries: \(detail.productionCountries.map { $0.name }.joined(separator: ", "))")
                .font(.caption)
                .foregroundColor(.secondary)
        }

        if let budget = detail.budget, budget > 0 {
            Text("Budget: \(budget.formattedWithSeparator()) USD")
                .font(.caption)
                .foregroundColor(.secondary)
        }

        if let revenue = detail.revenue, revenue > 0 {
            Text("Revenue: \(revenue.formattedWithSeparator()) USD")
                .font(.caption)
                .foregroundColor(.secondary)
        }

        if let status = detail.status {
            Text("Status: \(status)")
                .font(.caption)
                .foregroundColor(.secondary)
        }

        if let homepageURL = detail.homepageURL {
            Link("Official Website", destination: homepageURL)
                .font(.caption)
                .foregroundColor(.blue)
        }
    }
}

#Preview("With Detail") {
    MovieDetailInfoView.previewWithDetail.withPreviewNavigation()
}

#Preview("Empty Detail") {
    MovieDetailInfoView.previewWithEmptyDetail.withPreviewNavigation()
}

#Preview("Loading State") {
    MovieDetailInfoView.previewLoading.withPreviewNavigation()
}

#Preview("No Detail (Fallback)") {
    MovieDetailInfoView.previewNoDetail.withPreviewNavigation()
}

/// Returns the number as a string with thousands separators (e.g. "1,000,000").
private extension Int {
    func formattedWithSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
