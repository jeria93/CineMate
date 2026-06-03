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
    let changeEmailFeedbackMessage: String?
    let changeEmailFeedbackColor: Color?
    let passwordResetFeedbackMessage: String?
    let passwordResetFeedbackColor: Color?
    let isSendingPasswordReset: Bool
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
                
                if let changeEmailFeedbackMessage, let changeEmailFeedbackColor {
                    Text(changeEmailFeedbackMessage)
                        .font(.footnote)
                        .foregroundStyle(changeEmailFeedbackColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Text("Email change is only available for email accounts.")
                    .foregroundStyle(Color.appTextSecondary)
            }
            
            if canSendPasswordReset {
                if let currentEmail {
                    Text("Reset links are sent to \(currentEmail).")
                        .foregroundStyle(Color.appTextSecondary)
                }
                
                Button(action: onChangePassword) {
                    if isSendingPasswordReset {
                        HStack(spacing: SharedUI.Spacing.small) {
                            ProgressView()
                            Text("Sending reset link...")
                        }
                    } else {
                        Text("Change password")
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isAuthenticating)
                
                if let passwordResetFeedbackMessage, let passwordResetFeedbackColor {
                    Text(passwordResetFeedbackMessage)
                        .font(.footnote)
                        .foregroundStyle(passwordResetFeedbackColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Text("Password reset is only available for email accounts.")
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }
}
