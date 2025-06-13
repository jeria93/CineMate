//
//  TrailerButtonView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-12.
//

import SwiftUI

struct TrailerButtonView: View {
    let movie: Movie
    @Environment(\.openURL) var openURL

    var body: some View {
        Button {
            let url = TrailerHelper.bestAvailableURL(for: movie)
            openURL(url)
        } label: {
            Label("Watch Trailer", systemImage: "play.rectangle.fill")
                .font(.caption)
                .fontWeight(.semibold)
                .padding(6)
                .foregroundStyle(.white)
                .background(Color.red.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview("Light") {
    TrailerButtonView(movie: PreviewData.starWars)
        .environment(\.openURL, OpenURLAction { _ in .handled })
        .padding()
}

#Preview("Dark") {
    TrailerButtonView(movie: PreviewData.starWars)
        .environment(\.openURL, OpenURLAction { _ in .handled })
        .padding()
        .preferredColorScheme(.dark)
}
