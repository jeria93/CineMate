//
//  PosterImageView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

extension PosterImageView {
    static var previewWorking: some View {
        PosterImageView(
            url: URL(string: "https://image.tmdb.org/t/p/w200/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg"),
            title: "Star Wars - Episode V",
            width: 80,
            height: 120
        )
        .padding()
    }

    static var previewNoPoster: some View {
        PosterImageView(
            url: nil,
            title: "No Poster",
            width: 80,
            height: 120
        )
        .padding()
    }

    static var previewInList: some View {
        List {
            PosterImageView(
                url: URL(string: "https://image.tmdb.org/t/p/w200/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg"),
                title: "Star Wars - Episode V",
                width: 80,
                height: 120
            )
        }
    }
}
