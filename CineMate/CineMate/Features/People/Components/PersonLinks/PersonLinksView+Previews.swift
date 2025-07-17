//
//  PersonLinksView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-29.
//

import SwiftUI

extension PersonLinksView {
    static var preview: some View {
        let ids = PersonLinksPreviewData.markHamill

        return PersonLinksView(
            imdbURL: URL(string: "https://www.imdb.com/name/\(ids.imdbId ?? "")"),
            tmdbURL: URL(string: "https://www.themoviedb.org/person/\(PreviewID.next())"),
            instagramURL: ids.instagramURL,
            twitterURL: ids.twitterURL,
            facebookURL: ids.facebookURL
        )
        .padding()
        .background(Color(.systemBackground))
    }
}
