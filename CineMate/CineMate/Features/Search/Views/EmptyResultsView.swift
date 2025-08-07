//
//  EmptyResultsView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

struct EmptyResultsView: View {
    let query: String

    var body: some View {
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: "film")
                    .font(.system(size: 32))
                    .foregroundStyle(.secondary)

                Text("No results for \"\(query)\"")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text("Try a different movie title.")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            .multilineTextAlignment(.center)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .padding()
        }
    }
}

#Preview("EmptyResultsView") {
    EmptyResultsView(query: "Spiderman")
}
