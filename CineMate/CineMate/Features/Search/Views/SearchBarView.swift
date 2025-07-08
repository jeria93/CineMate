//
//  SearchBarView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search movies...", text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .onChange(of: text) {
                    if text.hasPrefix(" ") {
                        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }

            if !text.isEmpty {
                Button {
                    withAnimation { text = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .transition(.scale)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview("SearchBarView") {
    SearchBarView(text: .constant("Star Wars"))
}
