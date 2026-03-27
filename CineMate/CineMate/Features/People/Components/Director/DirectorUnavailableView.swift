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
                .foregroundStyle(Color.appTextSecondary)

            Text("No director information available.")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.appSurface)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.appTextSecondary.opacity(0.18), lineWidth: 1)
        )
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
            .background(Color.appBackground)
    }
}
