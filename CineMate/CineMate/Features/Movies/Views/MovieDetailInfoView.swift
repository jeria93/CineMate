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
    let watchProviderAvailability: WatchProviderAvailability?
    let isWatchProvidersLoading: Bool
    let watchProviderErrorMessage: String?
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
                .foregroundStyle(Color.appTextPrimary)

            HStack(spacing: 10) {
                if let releaseDateText {
                    Text("Release: \(releaseDateText)")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }

                if let voteAverageValue {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color.appPositive)
                            .font(.caption)
                        Text(String(format: "%.1f", voteAverageValue))
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
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
                    .foregroundStyle(Color.appTextSecondary)
            }

            WatchProvidersView(
                movieId: detail?.id ?? movie.id,
                availability: watchProviderAvailability,
                isLoading: isWatchProvidersLoading,
                errorMessage: watchProviderErrorMessage
            )

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
                .foregroundStyle(Color.appTextSecondary)
        }

        if !detail.productionCompanies.isEmpty {
            Text("Produced by: \(detail.productionCompanies.map { $0.name }.joined(separator: ", "))")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }

        if !detail.productionCountries.isEmpty {
            Text("Countries: \(detail.productionCountries.map { $0.name }.joined(separator: ", "))")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }

        if let budget = detail.budget, budget > 0 {
            Text("Budget: \(budget.formattedWithSeparator()) USD")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }

        if let revenue = detail.revenue, revenue > 0 {
            Text("Revenue: \(revenue.formattedWithSeparator()) USD")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }

        if let status = detail.status {
            Text("Status: \(status)")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }

        if let homepageURL = detail.homepageURL {
            Link("Official Website", destination: homepageURL)
                .font(.caption)
                .foregroundStyle(Color.appPrimaryAction)
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
