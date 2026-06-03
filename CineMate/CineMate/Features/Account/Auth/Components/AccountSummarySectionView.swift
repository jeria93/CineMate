//
//  AccountSummarySectionView.swift
//  CineMate
//
//  Created by OpenAI Codex on 2026-06-03.
//

import SwiftUI

/// Top account summary shown above the detailed account sections.
/// It is designed to handle long provider labels and email values without truncation-heavy layouts.
struct AccountSummarySectionView: View {
    let title: String
    let detail: String?
    let iconSystemName: String
    let providerDescription: String
    let userID: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: SharedUI.Spacing.small) {
            HStack(alignment: .center, spacing: SharedUI.Spacing.medium) {
                Image(systemName: iconSystemName)
                    .font(.title2)
                    .foregroundStyle(Color.appPrimaryAction)
                
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            if let detail {
                Text(detail)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            summaryRow(title: "Sign-in method", value: providerDescription)
            
            if let userID {
                summaryRow(
                    title: "User ID",
                    value: userID,
                    usesMonospacedValue: true
                )
            }
        }
        .padding(.vertical, 4)
    }
}

private extension AccountSummarySectionView {
    @ViewBuilder
    func summaryRow(
        title: String,
        value: String,
        usesMonospacedValue: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
            
            Text(value)
                .font(usesMonospacedValue ? .footnote.monospaced() : .body)
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
