//
//  ErrorMessageView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

struct ErrorMessageView: View {
    let title: String
    let message: String
    var onRetry: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.orange)

            Text(title)
                .font(.headline)

            Text(message)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let onRetry {
                Button("Try Again", action: onRetry)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
}

#Preview("Default Error") {
    ErrorMessageView(
        title: "Oops! Something went wrong.",
        message: "Unable to connect to the server."
    )
}

#Preview("Error with Retry") {
    ErrorMessageView(
        title: "Failed to Load",
        message: "Please check your internet connection.",
        onRetry: { print("Retry tapped!") }
    )
}
#Preview("Default Error") {
    ErrorMessageView(
        title: "Oops! Something went wrong.",
        message: "Unable to connect to the server."
    )
}

#Preview("Error with Retry") {
    ErrorMessageView(
        title: "Failed to Load",
        message: "Please check your internet connection.",
        onRetry: { print("Retry tapped!") }
    )
}

