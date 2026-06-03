//
//  AccountLegalSectionView.swift
//  CineMate
//
//  Created by OpenAI Codex on 2026-06-03.
//

import SwiftUI

/// Legal acceptance section for viewing current status and accepting newer terms.
struct AccountLegalSectionView: View {
    let summaryText: String?
    let shouldShowAcceptLatest: Bool
    let isAuthenticating: Bool
    let feedbackMessage: String?
    let feedbackColor: Color?
    let isAcceptingLatestTerms: Bool
    let onViewTerms: () -> Void
    let onAcceptLatest: () -> Void
    
    var body: some View {
        Section("Legal") {
            if let summaryText {
                Text(summaryText)
                    .foregroundStyle(Color.appTextSecondary)
            } else {
                Text("No saved legal acceptance for this account yet.")
                    .foregroundStyle(Color.appTextSecondary)
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
                .tint(.appPrimaryAction)
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
