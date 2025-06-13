//
//  Movie+TrailerURL.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-12.
//

import Foundation

extension Movie {
    var youtubeTrailerQuery: String {
        "\(title) trailer".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? title
    }

    var youtubeAppTrailerURL: URL? {
        URL(string: "youtube://www.youtube.com/results?search_query=\(youtubeTrailerQuery)")
    }

    var youtubeTrailerSearchURL: URL {
        URL(string: "https://www.youtube.com/results?search_query=\(youtubeTrailerQuery)")!
    }
}
