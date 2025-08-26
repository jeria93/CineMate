//
//  AccountView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

struct AccountView: View {
    @ObservedObject private var viewModel: AuthViewModel

    init(viewModel: AuthViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {

        VStack(spacing: 12) {
            Label("Account", systemImage: "person.crop.circle")
                .font(.headline)

            if let uid = viewModel.currentUID {
                Text("Signed in as: \(uid.prefix(6))")
                    .foregroundStyle(.secondary)

                Button("Sign Out") {
                    viewModel.signOut()
                }
                .buttonStyle(.borderedProminent)
            }
            contentStates
        }
    }

    @ViewBuilder
    private var contentStates: some View {
        if let errorMessage = viewModel.errorMessage {
            ErrorMessageView(
                title: "Error signing in",
                message: errorMessage
            )
        } else if viewModel.isAuthenticating {
            LoadingView(title: "Signing in...")
                .transition(.opacity)
        }
    }
}

#Preview("Signed In") {
    AccountView.previewSignedIn
}

#Preview("Signed Out") {
    AccountView.previewSignedOut
}

#Preview("Error") {
    AccountView.previewError
}

#Preview("Is Authenticating") {
    AccountView.previewIsAuthenticating
}
