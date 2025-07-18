//
//  DirectorUnavailableView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-29.
//

import SwiftUI

struct DirectorUnavailableView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)

            Text("No director information available.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview("Unavailable") {
    DirectorUnavailableView.previewUnavailable
}

extension DirectorUnavailableView {
    /// Shows the default unavailable state with placeholder image and message
    static var previewUnavailable: some View {
        DirectorUnavailableView()
            .padding()
            .background(Color(.systemBackground))
    }
}
