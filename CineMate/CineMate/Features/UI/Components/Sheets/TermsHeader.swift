//
//  TermsHeader.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-04-10.
//

import SwiftUI

struct TermsHeader: View {
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.appSurface.opacity(0.16))
                    .frame(width: 64, height: 64)
                    .overlay(Circle().strokeBorder(AuthTheme.cardStroke))
                Image(systemName: "doc.text")
                    .font(.system(size: 24, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(AuthTheme.iconOnCurtain)
            }
            Text("Terms of Service")
                .font(.title3.bold())
                .foregroundStyle(AuthTheme.iconOnCurtain)
            
            Text("Please review before creating an account")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, SharedUI.Spacing.large)
        }
        .padding(.top, 15)
    }
}
