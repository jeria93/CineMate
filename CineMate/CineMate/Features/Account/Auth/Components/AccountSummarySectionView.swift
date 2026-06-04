//
//  AccountSummarySectionView.swift
//  CineMate
//
//  Created by OpenAI Codex on 2026-06-03.
//

import SwiftUI

/// Top account summary shown above the detailed account sections.
/// It delegates copy actions so pasteboard and toast ownership stay in AccountView.
struct AccountSummarySectionView: View {
    let title: String
    let detail: String?
    let iconSystemName: String
    let providerDescription: String
    let userID: String?
    let copyEmail: String?
    let copyUserID: String?
    let onCopyEmail: (String) -> Void
    let onCopyUserID: (String) -> Void
    
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
            
            if let copyEmail {
                copyButton(
                    title: "Copy email",
                    value: copyEmail,
                    action: onCopyEmail
                )
            }
            
            summaryRow(title: "Sign-in method", value: providerDescription)
            
            if let userID {
                summaryRow(
                    title: "User ID",
                    value: userID,
                    usesMonospacedValue: true,
                    copyValue: copyUserID,
                    copyLabel: "Copy user ID",
                    onCopy: onCopyUserID
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
        usesMonospacedValue: Bool = false,
        copyValue: String? = nil,
        copyLabel: String? = nil,
        onCopy: ((String) -> Void)? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .center, spacing: SharedUI.Spacing.small) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                
                Spacer(minLength: SharedUI.Spacing.medium)
                
                if let copyValue, let copyLabel, let onCopy {
                    copyButton(
                        title: copyLabel,
                        value: copyValue,
                        action: onCopy
                    )
                }
            }
            
            Text(value)
                .font(usesMonospacedValue ? .footnote.monospaced() : .body)
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    func copyButton(
        title: String,
        value: String,
        action: @escaping (String) -> Void
    ) -> some View {
        Button {
            action(value)
        } label: {
            Label(title, systemImage: "doc.on.doc")
                .font(.footnote.weight(.medium))
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .tint(Color.appPrimaryAction)
    }
}
