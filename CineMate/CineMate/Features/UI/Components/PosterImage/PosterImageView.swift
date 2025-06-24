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
    let width: CGFloat
    let height: CGFloat

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
                        .frame(width: width, height: height)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                }
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "film")
                    .font(.largeTitle)
                    .frame(width: width, height: height)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview("Working poster") {
    PosterImageView.previewWorking
}

#Preview("No poster") {
    PosterImageView.previewNoPoster
}

#Preview("In List") {
    PosterImageView.previewInList
}
