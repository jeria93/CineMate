//
//  ExpandToggleButton.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-26.
//

import SwiftUI

struct ExpandToggleButton: View {
    let isExpanded: Bool
    let expandedLabel: String
    let collapsedLabel: String
    let systemImage: String?
    let action: () -> Void

    var body: some View {
        Button(action: {
            withAnimation { action() }
        }) {
            HStack(spacing: 4) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(isExpanded ? expandedLabel : collapsedLabel)
            }
            .font(.caption)
            .foregroundColor(.blue)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview("All ExpandToggleButton States") {
    VStack(spacing: 16) {
        ExpandToggleButton(
            isExpanded: false,
            expandedLabel: "Show less",
            collapsedLabel: "Read more",
            systemImage: "chevron.down"
        ) {}

        ExpandToggleButton(
            isExpanded: true,
            expandedLabel: "Show less",
            collapsedLabel: "Read more",
            systemImage: "chevron.up"
        ) {}

        ExpandToggleButton(
            isExpanded: false,
            expandedLabel: "Show less",
            collapsedLabel: "Read more",
            systemImage: nil
        ) {}

        ExpandToggleButton(
            isExpanded: true,
            expandedLabel: "Show less",
            collapsedLabel: "Read more",
            systemImage: nil
        ) {}
    }
    .padding()
    .background(Color(.systemBackground))
}
