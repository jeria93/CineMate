//
//  PosterImageView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import SwiftUI

struct PosterImageView: View {
    let url: URL?
    let title: String
    let width: CGFloat
    let height: CGFloat
    var cornerRadius: CGFloat
    var shadowRadius: CGFloat
    var onTap: (() -> Void)?

    @State private var isPressed = false

    init(
        url: URL?,
        title: String,
        width: CGFloat,
        height: CGFloat,
        cornerRadius: CGFloat = SharedUI.Radius.medium,
        shadowRadius: CGFloat = 1,
        onTap: (() -> Void)? = nil
    ) {
        self.url = url
        self.title = title
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.onTap = onTap
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
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(radius: shadowRadius)
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

    private func animateTap(action: () -> Void) {
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
