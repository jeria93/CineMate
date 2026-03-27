//
//  ExpandMoreCardView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-26.
//

import SwiftUI

struct ExpandMoreCardView: View {
    let remaining: Int
    let onTap: () -> Void

    var body: some View {
        Button(
            action: {
                withAnimation { onTap() }
            },
            label: {
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.appSurface)
                        .frame(width: 100, height: 150)
                        .overlay(
                            VStack(spacing: 4) {
                                Text("+\(remaining)")
                                    .font(.caption)
                                    .foregroundStyle(Color.appPrimaryAction)

                                Text("more")
                                    .font(.caption)
                                    .foregroundStyle(Color.appPrimaryAction)

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color.appPrimaryAction)
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.appTextSecondary.opacity(0.18), lineWidth: 1)
                        )

                    Text("")
                        .font(.caption)
                        .lineLimit(1)
                        .frame(height: 16)
                }
                .frame(width: 100)
            }
        )
        .buttonStyle(.plain)
    }
}

#Preview("ExpandMore Preview") {
    ExpandMoreCardView(remaining: 8) {
        print("Tapped +More")
    }
    .padding()
}
