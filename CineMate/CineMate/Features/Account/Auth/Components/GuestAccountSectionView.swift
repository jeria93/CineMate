//
//  GuestAccountSectionView.swift
//  CineMate
//
//  Created by OpenAI Codex on 2026-06-03.
//

import SwiftUI

/// Upgrade prompt shown for guest sessions inside the account screen.
struct GuestAccountSectionView: View {
    let isAuthenticating: Bool
    let onCreateAccount: () -> Void
    
    var body: some View {
        Section("Guest account") {
            Text("Create an account to unlock Discover and Search.")
                .foregroundStyle(Color.appTextSecondary)
            
            Button("Create Account", action: onCreateAccount)
                .buttonStyle(.borderedProminent)
                .tint(.appPrimaryAction)
                .disabled(isAuthenticating)
        }
    }
}
