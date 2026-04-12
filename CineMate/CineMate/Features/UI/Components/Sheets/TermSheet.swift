//
//  TermSheet.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-09-10.
//

import SwiftUI

struct TermsSheet: View {
    let markdown: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            let horizontalInset = max(SharedUI.Spacing.medium, min(SharedUI.Spacing.large, geometry.size.width * 0.04))

            ZStack {
                LinearGradient(
                    colors: [AuthTheme.curtainTop, AuthTheme.curtainBottom],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: SharedUI.Spacing.large) {
                    TermsHeader()
                        .padding(.top, SharedUI.Spacing.small)

                    ScrollView {
                        VStack(alignment: .leading, spacing: SharedUI.Spacing.large) {
                            ForEach(Array(termsBlocks.enumerated()), id: \.offset) { _, block in
                                TermsBlockView(block: block)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, SharedUI.Spacing.large)
                        .padding(.vertical, SharedUI.Spacing.xLarge)
                        .background(
                            RoundedRectangle(
                                cornerRadius: SharedUI.Radius.sheet,
                                style: .continuous
                            )
                            .fill(Color.appSurface.opacity(0.18))
                            .overlay(
                                RoundedRectangle(
                                    cornerRadius: SharedUI.Radius.sheet,
                                    style: .continuous
                                )
                                .stroke(AuthTheme.cardStroke)
                            )
                        )
                        .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
                        .padding(.horizontal, horizontalInset)
                        .padding(.vertical, SharedUI.Spacing.xSmall)
                    }
                    .scrollIndicators(.never)

                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.pillWhite)
                    .frame(height: 48)
                    .padding(.horizontal, horizontalInset)
                }
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.bottom, SharedUI.Spacing.large)
                .padding(.top, SharedUI.Spacing.xSmall)
            }
            .tint(AuthTheme.popcorn)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private var termsBlocks: [TermsBlock] {
        TermsMarkdownParser.parse(markdown)
    }
}

#Preview {
    TermsSheet(markdown: TermsContent.termsMarkdown)
}
