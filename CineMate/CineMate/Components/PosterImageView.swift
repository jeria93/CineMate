//
//  PosterImageView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import SwiftUI

struct PosterImageView: View {

    let url: URL?
    let title: String

    var body: some View {
        Group {
            if let url = url {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "film")
                        .font(.largeTitle)
                        .frame(width: 80, height: 120)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                }
                .frame(width: 80, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "film")
                    .font(.largeTitle)
                    .frame(width: 80, height: 120)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview("Working poster") {
    PosterImageView(
        url: URL(string: "https://image.tmdb.org/t/p/w200/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg"),
        title: "Star Wars - Episode V"
    )
}

#Preview("No poster") {
    PosterImageView(
        url: nil,
        title: "No Poster"
    )
}

#Preview("In List") {
    List {
        PosterImageView(
            url: URL(string: "https://image.tmdb.org/t/p/w200/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg"),
            title: "Star Wars - Episode V"
        )
    }
}
