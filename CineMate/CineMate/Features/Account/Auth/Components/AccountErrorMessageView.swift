//
//  AccountErrorMessageView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-06-03.
//

import SwiftUI

/// Inline fallback error shown on the account screen when no section-specific feedback is active.
struct AccountErrorMessageView: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: SharedUI.Spacing.small) {
            Label("Authentication Error", systemImage: "exclamationmark.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appDestructive)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Button("Dismiss", action: onDismiss)
                .buttonStyle(.bordered)
                .tint(.appPrimaryAction)
        }
        .padding(.vertical, 2)
    }
}
