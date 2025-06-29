//
//  TMDBImageHelper.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-26.
//

import Foundation

/// Represents available image sizes from The Movie Database (TMDB) API.
///
/// Adjust sizes based on your layout or display requirements.
/// For more, see: https://developer.themoviedb.org/docs/image-basics
enum TMDBImageSize: String {
    case w185
    case w342
    case w500
    case h632
}


/// A helper for building TMDB image URLs based on image path and size.
struct TMDBImageHelper {
    private static let baseURL = "https://image.tmdb.org/t/p/"

    /// Constructs a full TMDB image URL.
    ///
    /// - Parameters:
    ///   - path: The image path string (e.g. `/abc123.jpg`).
    ///   - size: The desired `TMDBImageSize`.
    /// - Returns: A fully qualified `URL` or `nil` if `path` is invalid.
    static func url(for path: String?, size: TMDBImageSize) -> URL? {
        guard let path else { return nil }
        return URL(string: "\(baseURL)\(size.rawValue)\(path)")
    }
}
