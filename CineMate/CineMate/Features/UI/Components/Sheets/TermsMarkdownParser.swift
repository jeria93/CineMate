//
//  TermsMarkdownParser.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-04-10.
//

import Foundation

enum TermsBlock {
    case heading(String)
    case quote(String)
    case paragraph(String)
}

enum TermsMarkdownParser {
    static func parse(_ markdown: String) -> [TermsBlock] {
        var blocks: [TermsBlock] = []
        var paragraphLines: [String] = []

        func flushParagraph() {
            let paragraph = paragraphLines.joined(separator: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !paragraph.isEmpty else { return }
            blocks.append(.paragraph(paragraph))
            paragraphLines.removeAll()
        }

        for line in markdown.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                flushParagraph()
                continue
            }

            if trimmed.hasPrefix("## ") {
                flushParagraph()
                blocks.append(.heading(String(trimmed.dropFirst(3))))
                continue
            }

            if trimmed.hasPrefix("> ") {
                flushParagraph()
                blocks.append(.quote(String(trimmed.dropFirst(2))))
                continue
            }

            paragraphLines.append(trimmed)
        }

        flushParagraph()
        return blocks
    }
}
