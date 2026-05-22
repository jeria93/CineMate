//
//  TermsHeader.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-04-10.
//

import SwiftUI

struct TermsHeader: View {
    let iconSystemName: String
    let title: String
    let subtitle: String

    init(
        iconSystemName: String = "doc.text",
        title: String = "Terms of Service",
        subtitle: String = "Please review before creating an account"
    ) {
        self.iconSystemName = iconSystemName
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.appSurface.opacity(0.16))
                    .frame(width: 64, height: 64)
                    .overlay(Circle().strokeBorder(AuthTheme.cardStroke))
                Image(systemName: iconSystemName)
                    .font(.system(size: 24, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(AuthTheme.iconOnCurtain)
            }
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(AuthTheme.iconOnCurtain)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, SharedUI.Spacing.large)
        }
        .padding(.top, 15)
    }
}
