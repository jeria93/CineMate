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
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(Circle())
    }
}

#Preview("With URL") {
    DirectorImageView(url: URL(string: "https://example.com/image.jpg"))
        .padding()
        .background(Color(.systemBackground))
}

#Preview("No URL / Fallback") {
    DirectorImageView(url: nil)
        .padding()
        .background(Color(.systemBackground))
}
