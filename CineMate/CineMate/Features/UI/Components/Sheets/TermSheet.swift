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
        ZStack {
            LinearGradient(colors: [AuthTheme.curtainTop, AuthTheme.curtainBottom],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            VStack(spacing: 22) {
                TermsHeader()

                ScrollView {
                    Text(markdownAttributed)
                        .lineSpacing(6)
                        .foregroundStyle(.white.opacity(0.92))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(AuthTheme.cardStroke)
                                )
                        )
                        .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
                        .padding(.horizontal, 20)
                }
                .scrollIndicators(.never)

                Button {
                    dismiss()
                } label: {
                    Text("Close").fontWeight(.semibold).frame(maxWidth: .infinity)
                }
                .buttonStyle(.pillWhite)
                .frame(height: 48)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 16)
        }
        .tint(AuthTheme.popcorn)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Helper
    private var markdownAttributed: AttributedString {
        (try? AttributedString(markdown: markdown)) ?? AttributedString(markdown)
    }
}

private struct TermsHeader: View {
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 64, height: 64)
                    .overlay(Circle().strokeBorder(AuthTheme.cardStroke))
                Image(systemName: "doc.text")
                    .font(.system(size: 24, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(AuthTheme.iconOnCurtain)
            }
            Text("Terms of Service")
                .font(.title3.bold())
                .foregroundStyle(.white)
            
            Text("Please review before creating an account")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.top, 15)
    }
}

#Preview {
    TermsSheet(markdown: TermsContent.termsMarkdown)
}
