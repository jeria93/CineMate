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
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: "film")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.appTextSecondary)

                Text("No results for \"\(query)\"")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)

                Text("Try a different movie title.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)

            }
            .multilineTextAlignment(.center)
            .padding()
            .background(

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.appSurface.opacity(0.96))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.appTextSecondary.opacity(0.18), lineWidth: 1)
            )
            .padding()
        }
    }
}

#Preview("EmptyResultsView") {
    EmptyResultsView(query: "Spiderman")
}
