//
//  SearchBarView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var isDisabled: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.appTextSecondary)

            TextField(
                isDisabled ? "Search is locked for guests" : "Search movies...",
                text: $text
            )
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .disabled(isDisabled)
            .onChange(of: text) {
                if text.hasPrefix(" ") {
                    text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }

            if !text.isEmpty && !isDisabled {
                Button {
                    withAnimation { text = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.appTextSecondary)
                }
                .transition(.scale)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.appSurface.opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.appTextSecondary.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: Color.tmdbNavy.opacity(0.10), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .opacity(isDisabled ? 0.8 : 1)
    }
}

#Preview("SearchBarView") {
    SearchBarView(text: .constant("Star Wars"))
}
