//
//  GuestAccountSectionView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-06-03.
//

import SwiftUI

/// Explains account value for guest users before routing to account creation.
struct GuestAccountSectionView: View {
    let isAuthenticating: Bool
    let onCreateAccount: () -> Void
    
    var body: some View {
        Section("Guest account") {
            VStack(alignment: .leading, spacing: SharedUI.Spacing.medium) {
                Label("Get more out of CineMate", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                
                Text("Create an account to unlock more features and keep your profile available across sessions.")
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: SharedUI.Spacing.small) {
                    benefitRow(
                        iconSystemName: "safari.fill",
                        title: "Unlock Discover"
                    )
                    benefitRow(
                        iconSystemName: "magnifyingglass",
                        title: "Unlock Search"
                    )
                    benefitRow(
                        iconSystemName: "lock.shield.fill",
                        title: "Keep your data across sessions"
                    )
                }
            }
            .padding(.vertical, 2)
            
            Button("Create account and unlock features", action: onCreateAccount)
                .buttonStyle(.borderedProminent)
                .tint(.appPrimaryAction)
                .disabled(isAuthenticating)
        }
    }
}

private extension GuestAccountSectionView {
    @ViewBuilder
    func benefitRow(iconSystemName: String, title: String) -> some View {
        HStack(alignment: .center, spacing: SharedUI.Spacing.medium) {
            Image(systemName: iconSystemName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appPrimaryAction)
                .frame(width: SharedUI.Size.iconButton, alignment: .center)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
