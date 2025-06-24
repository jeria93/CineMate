//
//  MovieDetailInfoView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-10.
//

import SwiftUI

struct MovieDetailInfoView: View {
    let movie: Movie
    @ObservedObject var viewModel: MovieViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text(movie.title)
                .font(.largeTitle.bold())

            HStack(spacing: 10) {
                if let releaseDate = movie.releaseDate {
                    Text("Release: \(releaseDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let vote = movie.voteAverage {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", vote))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            if let genres = movie.genres, !genres.isEmpty {
                MovieGenresView(genres: genres)
            }

            if let overview = movie.overview {
                Text(overview)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            if let detail = viewModel.movieDetail {
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

                if let homepage = detail.homepage, let url = URL(string: homepage) {
                    Link("🌐 Official Website", destination: url)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

#Preview("With Detail") {
    MovieDetailInfoView.previewWithDetail
}

#Preview("Empty Detail") {
    MovieDetailInfoView.previewWithEmptyDetail
}

extension Int {
    func formattedWithSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
