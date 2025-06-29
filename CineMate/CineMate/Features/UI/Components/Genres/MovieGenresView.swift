//
//  MovieGenresView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-11.
//

import SwiftUI

struct MovieGenresView: View {
    let genres: [String]

    var body: some View {
        if genres.isEmpty {
            Text("Genres not available")
                .font(.caption)
                .foregroundColor(.secondary)
        } else {
            HStack {
                ForEach(genres, id: \.self) { genre in
                    Text(genre)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        }
    }
}

#Preview {
    MovieGenresView(genres: ["Action", "Adventure", "Animation"])
}
