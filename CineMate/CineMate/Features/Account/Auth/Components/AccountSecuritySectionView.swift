//
//  AccountSecuritySectionView.swift
//  CineMate
//
//  Created by OpenAI Codex on 2026-06-03.
//

import SwiftUI

/// Shows security status and local feedback while AccountView owns async auth actions.
struct AccountSecuritySectionView: View {
    let currentEmail: String?
    let status: AccountSecurityStatus
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
            statusHeader(
                title: status.title,
                detail: status.detail,
                iconSystemName: status.iconSystemName,
                tint: status.tint
            )
            
            if let currentEmail {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Current email")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                    
                    Text(currentEmail)
                        .textSelection(.enabled)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            if canChangeEmail {
                Text("Send a verification link before changing your account email.")
                    .font(.footnote)
                    .foregroundStyle(Color.appTextSecondary)
                
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
                    Text("Password reset links are sent to \(currentEmail).")
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Button(action: onChangePassword) {
                    if isSendingPasswordReset {
                        HStack(spacing: SharedUI.Spacing.small) {
                            ProgressView()
                            Text("Sending reset link...")
                        }
                    } else {
                        Text("Send reset link")
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

private extension AccountSecuritySectionView {
    @ViewBuilder
    func statusHeader(
        title: String,
        detail: String,
        iconSystemName: String,
        tint: Color
    ) -> some View {
        HStack(alignment: .top, spacing: SharedUI.Spacing.medium) {
            Image(systemName: iconSystemName)
                .font(.title3)
                .foregroundStyle(tint)
                .frame(width: SharedUI.Size.iconButton)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
