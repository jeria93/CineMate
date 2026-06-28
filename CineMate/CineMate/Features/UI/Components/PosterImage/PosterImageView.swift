//
//  PosterImageView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import SwiftUI

/// Loads a poster image with fallback artwork and optional tap animation.
struct PosterImageView: View {
    let url: URL?
    let title: String
    let configuration: PosterImageConfiguration
    var onTap: (() -> Void)?

    @State private var isPressed = false

    init(
        url: URL?,
        title: String,
        configuration: PosterImageConfiguration,
        onTap: (() -> Void)? = nil
    ) {
        self.url = url
        self.title = title
        self.configuration = configuration
        self.onTap = onTap
    }

    init(
        url: URL?,
        title: String,
        width: CGFloat,
        height: CGFloat,
        cornerRadius: CGFloat = SharedUI.Radius.medium,
        shadowRadius: CGFloat = 1,
        onTap: (() -> Void)? = nil
    ) {
        self.init(
            url: url,
            title: title,
            configuration: PosterImageConfiguration(
                size: CGSize(width: width, height: height),
                cornerRadius: cornerRadius,
                shadowRadius: shadowRadius
            ),
            onTap: onTap
        )
    }

    var body: some View {
        Group {
            if let onTap {
                Button(
                    action: { animateTap(action: onTap) },
                    label: { imageBody }
                )
                .buttonStyle(.plain)
                .scaleEffect(isPressed ? 0.97 : 1)
                .animation(.spring(response: 0.28, dampingFraction: 0.75), value: isPressed)
                .accessibilityAddTraits(.isButton)
            } else {
                imageBody
            }
        }
        .accessibilityLabel(title)
    }

    private var imageBody: some View {
        imageContent
            .frame(width: configuration.size.width, height: configuration.size.height)
            .clipShape(RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous))
            .shadow(radius: configuration.shadowRadius)
    }

    @ViewBuilder
    private var imageContent: some View {
        if ProcessInfo.processInfo.isPreview {
            fallbackPoster
        } else if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    fallbackPoster
                @unknown default:
                    fallbackPoster
                }
            }
        } else {
            fallbackPoster
        }
    }

    private var fallbackPoster: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.22))

            Image(systemName: "film")
                .font(.largeTitle)
                .foregroundStyle(.white.opacity(0.65))
        }
    }

    private func animateTap(action: @escaping () -> Void) {
        isPressed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            isPressed = false
            action()
        }
    }
}

#Preview("Working poster") {
    PosterImageView.previewWorking
}

#Preview("No poster") {
    PosterImageView.previewNoPoster
}

#Preview("In List") {
    PosterImageView.previewInList
}
