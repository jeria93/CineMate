//
//  AccountDangerZoneView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-09-03.
//

import SwiftUI

struct AccountDangerZoneView: View {
    @ObservedObject var authViewModel: AuthViewModel
    let onReauthenticationRequired: () -> Void
    let onDeleteSuccess: () -> Void
    let onDeleteFailure: (String) -> Void

    @State private var isShowingDeleteAlert = false

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Danger Zone")
                    .font(.headline)

                Text("Delete your account and remove all data. This action cannot be undone")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button(role: .destructive) {
                    isShowingDeleteAlert = true
                } label: {
                    Text("Delete Account")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(authViewModel.isAuthenticating)
                .alert("Delete account?", isPresented: $isShowingDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        Task { await deleteAccount() }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This will permanently remove your account and data")
                }
            }
            .padding(.vertical, 4)
        }
    }

    @MainActor
    private func deleteAccount() async {
        switch await authViewModel.deleteCurrentAccount() {
        case .success:
            onDeleteSuccess()
        case .needsRecentLogin:
            onReauthenticationRequired()
        case .failure(let message):
            onDeleteFailure(message)
        }
    }
}

#Preview("Default (static)") {
    Form {
        AccountDangerZoneView(
            authViewModel: AuthViewModel(simulatedUID: "preview-uid"),
            onReauthenticationRequired: {},
            onDeleteSuccess: {},
            onDeleteFailure: { _ in }
        )
    }
}

#Preview("Loading") {
    Form {
        AccountDangerZoneView(
            authViewModel: AuthViewModel(
                simulatedUID: "preview-uid",
                previewError: nil,
                previewIsAuthenticating: true
            ),
            onReauthenticationRequired: {},
            onDeleteSuccess: {},
            onDeleteFailure: { _ in }
        )
    }
}
