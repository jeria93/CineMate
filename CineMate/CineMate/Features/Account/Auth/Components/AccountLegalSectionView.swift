//
//  AccountLegalSectionView.swift
//  CineMate
//
//  Created by OpenAI Codex on 2026-06-03.
//

import SwiftUI

/// Shows legal acceptance status, stored versions, refresh metadata, and local feedback.
struct AccountLegalSectionView: View {
    let status: AccountLegalStatus
    let acceptedTermsVersionText: String?
    let acceptedPrivacyVersionText: String?
    let lastCheckedText: String?
    let shouldShowAcceptLatest: Bool
    let isAuthenticating: Bool
    let feedbackMessage: String?
    let feedbackColor: Color?
    let isAcceptingLatestTerms: Bool
    let onViewTerms: () -> Void
    let onAcceptLatest: () -> Void
    
    var body: some View {
        Section("Legal") {
            statusHeader(
                title: status.title,
                detail: status.detail,
                iconSystemName: status.iconSystemName,
                tint: status.tint
            )
            
            VStack(alignment: .leading, spacing: SharedUI.Spacing.xSmall) {
                if let acceptedTermsVersionText {
                    metadataRow(title: "Terms", value: acceptedTermsVersionText)
                }
                
                if let acceptedPrivacyVersionText {
                    metadataRow(title: "Privacy", value: acceptedPrivacyVersionText)
                }
                
                if let acceptedAtText = status.acceptedAtText {
                    metadataRow(title: "Accepted", value: acceptedAtText)
                }
                
                if let lastCheckedText {
                    metadataRow(title: "Last checked", value: lastCheckedText)
                }
            }
            
            Button("View terms", action: onViewTerms)
                .buttonStyle(.bordered)
                .disabled(isAuthenticating)
            
            if shouldShowAcceptLatest {
                Button(action: onAcceptLatest) {
                    if isAcceptingLatestTerms {
                        HStack(spacing: SharedUI.Spacing.small) {
                            ProgressView()
                            Text("Saving acceptance...")
                        }
                    } else {
                        Text("Accept latest")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.appPrimaryAction)
                .disabled(isAuthenticating)
            }
            
            if let feedbackMessage, let feedbackColor {
                Text(feedbackMessage)
                    .font(.footnote)
                    .foregroundStyle(feedbackColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private extension AccountLegalSectionView {
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
    
    @ViewBuilder
    func metadataRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
            
            Spacer(minLength: SharedUI.Spacing.large)
            
            Text(value)
                .font(.footnote)
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.trailing)
        }
    }
}
