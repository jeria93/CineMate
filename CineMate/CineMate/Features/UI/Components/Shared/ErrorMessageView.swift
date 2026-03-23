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
    let retryTitle: String
    var onRetry: (() -> Void)?

    init(
        title: String,
        message: String,
        retryTitle: String = "Try Again",
        onRetry: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.retryTitle = retryTitle
        self.onRetry = onRetry
    }

    var body: some View {
        OverlayContainer(backdrop: .material) {
            OverlayCard {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.orange)
                    .accessibilityHidden(true)

                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(message)
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let onRetry {
                    Button(retryTitle, action: onRetry)
                        .buttonStyle(.borderedProminent)
                        .padding(.top, SharedUI.Spacing.small)
                        .accessibilityHint("Attempts to load the content again")
                }
            }
        }
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
