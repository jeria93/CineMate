////
////  MovieRowView+Previews.swift
////  CineMate
////
////  Created by Nicholas Samuelsson Jeria on 2025-06-08.
////
//
//import SwiftUI
//
///// Preview variants for `MovieRowView`.
/////
///// Simulates different movie data states to test UI layout and robustness:
///// - Full movie data
///// - Missing poster
///// - Missing overview
///// - Extremely long overview
///// - Minimal data (e.g. only title)
//extension MovieRowView {
//
//    /// Preview with full movie data.
//    ///
//    /// Uses `SharedPreviewMovies.starWars` with poster and overview.
//    static var previewDefault: some View {
//        PreviewID.reset()
//        return MovieRowView(movie: SharedPreviewMovies.starWars)
//            .padding()
//            .background(Color(.systemGroupedBackground))
//    }
//
//    /// Preview with missing poster image.
//    ///
//    /// All other data is included.
//    static var previewNoPoster: some View {
//        MovieRowView(
//            movie: Movie(
//                id: PreviewID.next(),
//                title: SharedPreviewMovies.starWars.title,
//                overview: SharedPreviewMovies.starWars.overview,
//                posterPath: nil,
//                backdropPath: SharedPreviewMovies.starWars.backdropPath,
//                releaseDate: SharedPreviewMovies.starWars.releaseDate,
//                voteAverage: SharedPreviewMovies.starWars.voteAverage,
//                genres: SharedPreviewMovies.starWars.genres
//            )
//        )
//        .padding()
//        .background(Color(.systemGroupedBackground))
//    }
//
//    /// Preview with missing overview text.
//    ///
//    /// Useful to test layout when overview is `nil`.
//    static var previewNoOverview: some View {
//        MovieRowView(
//            movie: Movie(
//                id: PreviewID.next(),
//                title: SharedPreviewMovies.starWars.title,
//                overview: nil,
//                posterPath: SharedPreviewMovies.starWars.posterPath,
//                backdropPath: SharedPreviewMovies.starWars.backdropPath,
//                releaseDate: SharedPreviewMovies.starWars.releaseDate,
//                voteAverage: SharedPreviewMovies.starWars.voteAverage,
//                genres: SharedPreviewMovies.starWars.genres
//            )
//        )
//        .padding()
//        .background(Color(.systemGroupedBackground))
//    }
//
//    /// Preview with extremely long overview text.
//    ///
//    /// Repeats the existing overview 10 times to simulate layout stress.
//    static var previewLongOverview: some View {
//        MovieRowView(
//            movie: Movie(
//                id: PreviewID.next(),
//                title: SharedPreviewMovies.starWars.title,
//                overview: String(repeating: SharedPreviewMovies.starWars.overview ?? "", count: 10),
//                posterPath: SharedPreviewMovies.starWars.posterPath,
//                backdropPath: SharedPreviewMovies.starWars.backdropPath,
//                releaseDate: SharedPreviewMovies.starWars.releaseDate,
//                voteAverage: SharedPreviewMovies.starWars.voteAverage,
//                genres: SharedPreviewMovies.starWars.genres
//            )
//        )
//        .padding()
//        .background(Color(.systemGroupedBackground))
//    }
//
//    /// Preview with minimal movie data.
//    ///
//    /// Only title is guaranteed; all other fields may be `nil`.
//    static var previewMinimalData: some View {
//        MovieRowView(movie: SharedPreviewMovies.minimalMovie)
//            .padding()
//            .background(Color(.systemGroupedBackground))
//    }
//}
