//
//  OrDivider.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-09-10.
//

import SwiftUI

/// A horizontal separator with a centered label, e.g. "OR CONTINUE WITH".
/// Pass a localized `text`. The visual is uppercase.
struct OrDivider: View {
    let text: LocalizedStringKey
    var lineColor: Color = .white
    var lineOpacity: CGFloat = 0.35

    var body: some View {
        HStack(spacing: 12) {
            DividerLine(color: lineColor.opacity(lineOpacity))
            Text(text)
                .textCase(.uppercase) // visual only
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))
            DividerLine(color: lineColor.opacity(lineOpacity))
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

/// Thin separator line used by `OrDivider`.
private struct DividerLine: View {
    var color: Color
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
            .cornerRadius(1)
            .accessibilityHidden(true)
    }
}
