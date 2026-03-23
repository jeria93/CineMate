//
//  LockedFeatureOverlay.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-31.
//

import SwiftUI

enum OverlayBackdropStyle {
    case material
    case dimmed(CGFloat)
    case none
}

struct OverlayContainer<Content: View>: View {
    let backdrop: OverlayBackdropStyle
    var ignoresSafeArea = true
    @ViewBuilder var content: () -> Content

    init(
        backdrop: OverlayBackdropStyle = .material,
        ignoresSafeArea: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.backdrop = backdrop
        self.ignoresSafeArea = ignoresSafeArea
        self.content = content
    }

    var body: some View {
        Group {
            if ignoresSafeArea {
                container.ignoresSafeArea()
            } else {
                container
            }
        }
    }

    private var container: some View {
        ZStack {
            switch backdrop {
            case .material:
                Rectangle().fill(.ultraThinMaterial)
            case .dimmed(let opacity):
                Color.black.opacity(opacity)
            case .none:
                EmptyView()
            }

            content()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct OverlayCard<Content: View>: View {
    var maxWidth = SharedUI.Overlay.cardMaxWidth
    @ViewBuilder var content: () -> Content

    init(
        maxWidth: CGFloat = SharedUI.Overlay.cardMaxWidth,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.maxWidth = maxWidth
        self.content = content
    }

    var body: some View {
        VStack(spacing: SharedUI.Spacing.medium) {
            content()
        }
        .padding(SharedUI.Overlay.cardPadding)
        .frame(maxWidth: maxWidth)
        .background(
            RoundedRectangle(cornerRadius: SharedUI.Radius.large, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: SharedUI.Radius.large, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        )
        .shadow(radius: 18, y: SharedUI.Spacing.small)
        .padding(.horizontal, SharedUI.Spacing.xxLarge)
    }
}

struct LockedFeatureOverlay: View {
    let title: String
    let message: String?
    let ctaTitle: String
    let onCTA: () -> Void

    init(
        title: String = "Create a free account to continue",
        message: String? = nil,
        ctaTitle: String = "Create Account",
        onCTA: @escaping () -> Void = {}
    ) {
        self.title = title
        self.message = message
        self.ctaTitle = ctaTitle
        self.onCTA = onCTA
    }

    var body: some View {
        OverlayContainer(backdrop: .dimmed(SharedUI.Overlay.dimOpacity)) {
            OverlayCard {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)

                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                if let message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Button(ctaTitle, action: onCTA)
                    .buttonStyle(.borderedProminent)
            }
        }
        .contentShape(Rectangle())
        .allowsHitTesting(true)
        .transition(.opacity)
    }
}

#Preview("Default") {
    LockedFeatureOverlay()
}

#Preview("With message") {
    LockedFeatureOverlay(message: "Sign up to search and save favorites.")
}
