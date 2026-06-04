//
//  AccountDangerZoneView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-09-03.
//

import SwiftUI

/// Presents irreversible account deletion with clear risk copy and local confirmation.
struct AccountDangerZoneView: View {
    @ObservedObject var authViewModel: AuthViewModel
    let onReauthenticationRequired: () -> Void
    let onDeleteSuccess: () -> Void
    let onDeleteFailure: (String) -> Void
    
    @State private var isShowingDeleteAlert = false
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: SharedUI.Spacing.large) {
                HStack(alignment: .top, spacing: SharedUI.Spacing.medium) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.headline)
                        .foregroundStyle(Color.appDestructive)
                        .frame(width: SharedUI.Size.iconButton, height: SharedUI.Size.iconButton)
                        .background(
                            Circle()
                                .fill(Color.appDestructive.opacity(0.12))
                        )
                    
                    VStack(alignment: .leading, spacing: SharedUI.Spacing.xSmall) {
                        Text("Danger Zone")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                        
                        Text("Delete your account, saved favorites, favorite people, and account data.")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: SharedUI.Spacing.xSmall) {
                    Text("This cannot be undone.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    
                    Text("For security, CineMate may ask you to sign in again before deleting the account.")
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Button(role: .destructive) {
                    isShowingDeleteAlert = true
                } label: {
                    Text("Delete account")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(Color.appDestructive)
                .disabled(authViewModel.isAuthenticating)
                .alert("Permanently delete account?", isPresented: $isShowingDeleteAlert) {
                    Button("Delete account", role: .destructive) {
                        Task { await deleteAccount() }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This removes your account, saved favorites, favorite people, and account data. This cannot be undone.")
                }
            }
            .padding(.vertical, SharedUI.Spacing.small)
            .listRowBackground(Color.appDestructive.opacity(0.055))
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
