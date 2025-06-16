//
//  TrailerHelper.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-12.
//

import UIKit

struct TrailerHelper {

    static func bestAvailableURL(for movie: Movie) -> URL {
        if let appURL = movie.youtubeAppTrailerURL,
           UIApplication.shared.canOpenURL(appURL) {
            return appURL
        } else {
            return movie.youtubeTrailerSearchURL
        }
    }
}

