//
//  ShareHelper.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-11.
//

import Foundation
import UIKit

enum ShareHelper {

    /// Asynchronously creates a `MovieShareItem` for a given movie,
    /// including the title, a URL to the movie's TMDB page,
    /// and an image loaded from the poster URL.
    /// Returns `nil` if any step (poster URL missing, download failure, or image conversion) fails
    static func createShareItem(for movie: Movie) async -> MovieShareItem? {

        guard
            let posterURL = movie.posterSmallURL,
            let (data, _) = try? await URLSession.shared.data(from: posterURL),
            let image = UIImage(data: data)
        else { return nil }

        return MovieShareItem(
            title: movie.title,
            url: movie.tmdbURL,
            image: image
        )
    }
}

