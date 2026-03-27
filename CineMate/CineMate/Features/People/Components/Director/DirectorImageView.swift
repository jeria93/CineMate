//
//  DirectorImageView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-29.
//

import SwiftUI

struct DirectorImageView: View {
    let url: URL?

    var body: some View {
        imageView
        .frame(width: 60, height: 60)
        .clipShape(Circle())
    }

    @ViewBuilder
    private var imageView: some View {
        if ProcessInfo.processInfo.isPreview {
            fallbackImage
        } else {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    fallbackImage
                }
            }
        }
    }

    private var fallbackImage: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color.appTextSecondary)
            .padding(6)
            .background(Color.appSurface)
    }
}

#Preview("With URL") {
    DirectorImageView.previewWithImage
}

#Preview("No URL / Fallback") {
    DirectorImageView.previewFallback
}
