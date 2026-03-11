//
//  TrailerHelper.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-12.
//

import UIKit

struct TrailerHelper {

    static func bestAvailableURL(for movie: Movie, videos: [MovieVideo] = []) -> URL {
        if let trailerURL = preferredTrailerURL(from: videos) {
            return trailerURL
        }

        if let appURL = movie.youtubeAppTrailerURL,
           UIApplication.shared.canOpenURL(appURL) {
            return appURL
        }
        return movie.youtubeTrailerSearchURL
    }

    static func preferredTrailerURL(from videos: [MovieVideo]) -> URL? {
        let youtubeVideos = videos.filter { $0.site.caseInsensitiveCompare("YouTube") == .orderedSame }
        guard !youtubeVideos.isEmpty else { return nil }

        if let officialTrailer = youtubeVideos.first(where: {
            $0.type.caseInsensitiveCompare("Trailer") == .orderedSame &&
            $0.name.localizedCaseInsensitiveContains("official")
        }) {
            return youtubeWatchURL(videoKey: officialTrailer.key)
        }

        if let trailer = youtubeVideos.first(where: {
            $0.type.caseInsensitiveCompare("Trailer") == .orderedSame
        }) {
            return youtubeWatchURL(videoKey: trailer.key)
        }

        return youtubeWatchURL(videoKey: youtubeVideos[0].key)
    }
}

private extension TrailerHelper {
    static func youtubeWatchURL(videoKey: String) -> URL? {
        guard !videoKey.isEmpty else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(videoKey)")
    }
}
