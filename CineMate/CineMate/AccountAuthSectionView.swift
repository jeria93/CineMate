//
//  AccountAuthSectionView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-16.
//

import SwiftUI

struct AccountAuthSectionView: View {
    @ObservedObject private var viewModel: AuthViewModel

    init(viewModel: AuthViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            content
                .animation(.default, value: viewModel.currentUID)
                .animation(.default, value: viewModel.errorMessage)
                .animation(.default, value: viewModel.isAuthenticating)

            if viewModel.isAuthenticating {
                LoadingView(title: "Signing in…")
                    .transition(.opacity)
            }

            if let message = viewModel.errorMessage {
                ErrorMessageView(
                    title: "Sign-in failed",
                    message: message,
                    onRetry: { Task { await viewModel.signInAsGuest() } }
                )
                .transition(.opacity)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Content states

    @ViewBuilder
    private var content: some View {
        if let uid = viewModel.currentUID {
            signedInContent(uid: uid)
        } else {
            signedOutContent
        }
    }

    private func signedInContent(uid: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Authentication", systemImage: "person.badge.key")
                .font(.headline)

            HStack {
                Text("Status:")
                Text("Signed in as \(uid.prefix(6))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                Button("Sign out") { viewModel.signOut() }
                    .buttonStyle(.bordered)
            }
        }
    }

    private var signedOutContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Authentication", systemImage: "person.badge.key")
                .font(.headline)

            EmptyStateView(
                systemImage: "person.crop.circle.badge.questionmark",
                title: "You’re signed out",
                message: "Sign in to sync your favorites and use cloud features",
                actionTitle: "Continue as guest",
                onAction: {
                    Task {
                        await viewModel.signInAsGuest()
                    }
                }
            )
            .frame(maxWidth: .infinity, minHeight: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview("Signed out") {
    AccountAuthSectionView.previewSignedOut
}

#Preview("Signed in") {
    AccountAuthSectionView.previewSignedIn
}

#Preview("Error") {
    AccountAuthSectionView.previewError
}

#Preview("Is Authenticating") {
    AccountAuthSectionView.previewBusy
}
