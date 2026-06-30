//
//  AccountSessionSectionView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-06-03.
//

import SwiftUI

/// Session control section for ending a guest session or signing out of a full account.
struct AccountSessionSectionView: View {
    let isGuest: Bool
    let isAuthenticating: Bool
    let onSignOut: () -> Void
    
    var body: some View {
        Section("Session") {
            Button(isGuest ? "End guest session" : "Sign out", action: onSignOut)
                .buttonStyle(.borderedProminent)
                .tint(.appPrimaryAction)
                .disabled(isAuthenticating)
        }
    }
}
