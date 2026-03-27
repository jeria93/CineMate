//
//  AuthHeader.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-09-10.
//

import SwiftUI

/// Small, reusable header for auth screens (icon + title + subtitle).
/// Visual-only, strings are not localized here. Uses `AuthTheme` colors.
struct AuthHeader: View {
    var onIconLongPress: (() -> Void)?

    var body: some View {
        VStack(spacing: 10) {
            iconView
                .accessibilityHidden(true)

            Text("CineMate")
                .font(.title2).bold()
                .foregroundStyle(AuthTheme.iconOnCurtain)

            Text("Sign in to continue")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.top, 4)
    }

    private var iconContent: some View {
        ZStack {
            Circle()
                .fill(Color.appSurface.opacity(0.16))
                .frame(width: 72, height: 72)
                .overlay(Circle().strokeBorder(AuthTheme.cardStroke))
            Image(systemName: "film.fill")
                .font(.system(size: 28, weight: .bold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(AuthTheme.iconOnCurtain)
        }
    }

    @ViewBuilder
    private var iconView: some View {
        if let onIconLongPress {
            iconContent
                .onLongPressGesture(minimumDuration: 0.8, perform: onIconLongPress)
        } else {
            iconContent
        }
    }
}

#Preview { AuthHeader() }
