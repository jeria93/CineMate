//
//  GenreDetailView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-30.
//

import SwiftUI

struct GenreDetailView: View {
    let genreName: String

    var body: some View {
        VStack(spacing: 16) {
            Text("Under progress")
                .font(.title2.bold())
            Text("Genre: \(genreName)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle(genreName)
    }
}

#Preview {
    GenreDetailView(genreName: "Action")
}
