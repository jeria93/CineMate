//
//  AccountSecuritySectionView.swift
//  CineMate
//
//  Created by OpenAI Codex on 2026-06-03.
//

import SwiftUI

/// Security actions for email-based accounts.
/// The parent view handles the async work and passes simple action closures into this section.
struct AccountSecuritySectionView: View {
    let currentEmail: String?
    let canChangeEmail: Bool
    let canSendPasswordReset: Bool
    let isAuthenticating: Bool
    let onChangeEmail: () -> Void
    let onChangePassword: () -> Void
    
    var body: some View {
        Section("Security") {
            if let currentEmail {
                HStack {
                    Text("Current email")
                    Spacer()
                    Text(currentEmail)
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            if canChangeEmail {
                Button("Change email", action: onChangeEmail)
                    .buttonStyle(.bordered)
                    .disabled(isAuthenticating)
            } else {
                Text("Email change is only available for email accounts.")
                    .foregroundStyle(Color.appTextSecondary)
            }
            
            if canSendPasswordReset {
                if let currentEmail {
                    Text("Reset links are sent to \(currentEmail).")
                        .foregroundStyle(Color.appTextSecondary)
                }
                
                Button("Change password", action: onChangePassword)
                    .buttonStyle(.bordered)
                    .disabled(isAuthenticating)
            } else {
                Text("Password reset is only available for email accounts.")
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }
}
