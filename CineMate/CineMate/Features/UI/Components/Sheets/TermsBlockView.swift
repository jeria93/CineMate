//
//  TermsBlockView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-04-10.
//

import SwiftUI

struct TermsBlockView: View {
    let block: TermsBlock

    var body: some View {
        switch block {
        case .heading(let text):
            Text(text)
                .font(.headline.weight(.semibold))
                .foregroundStyle(AuthTheme.textOnCurtainPrimary)

        case .quote(let text):
            Text(markdownInline(text))
                .font(.callout)
                .lineSpacing(6)
                .foregroundStyle(AuthTheme.iconOnCurtain.opacity(0.92))
                .padding(.horizontal, SharedUI.Spacing.medium)
                .padding(.vertical, SharedUI.Spacing.small)
                .background(
                    Color.white.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: SharedUI.Radius.medium, style: .continuous)
                )

        case .paragraph(let text):
            Text(markdownInline(text))
                .font(.callout)
                .lineSpacing(7)
                .foregroundStyle(AuthTheme.iconOnCurtain.opacity(0.92))
        }
    }

    private func markdownInline(_ text: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        return (try? AttributedString(markdown: text, options: options)) ?? AttributedString(text)
    }
}
