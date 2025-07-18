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
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.gray)
                    .padding(6)
                    .background(Color.gray.opacity(0.1))
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(Circle())
    }
}

#Preview("With URL") {
    DirectorImageView.previewWithImage
}

#Preview("No URL / Fallback") {
    DirectorImageView.previewFallback
}
