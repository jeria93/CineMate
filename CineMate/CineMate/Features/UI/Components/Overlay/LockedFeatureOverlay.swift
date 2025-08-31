//
//  LockedFeatureOverlay.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-31.
//

import SwiftUI

struct LockedFeatureOverlay: View {
    let title: String = "Create a free account to continue"
    let message: String? = nil
    let onCTA: @MainActor () -> Void = {}

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.secondary)

                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                if let message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Button("Create Account", action: onCTA)
                    .buttonStyle(.borderedProminent)
            }
            .padding(18)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.quaternary, lineWidth: 1)
            )
            .shadow(radius: 18, y: 8)
            .padding(.horizontal, 24)
        }
        .contentShape(Rectangle())
        .allowsHitTesting(true)
        .transition(.opacity)
        .accessibilityAddTraits(.isModal)
    }
}

#Preview {
    LockedFeatureOverlay()
}
