//
//  AuthErrorBlock.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-26.
//

import SwiftUI

/// Small error view for auth screens.
/// It can also show a resend verification action.
struct AuthErrorBlock: View {

    /// Error text.
    let message: String

    /// Shows resend button when true.
    var showResend: Bool = false

    /// Called when user taps resend.
    var onResend: () -> Void = {}

    var body: some View {
        VStack(spacing: 8) {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
            
            if showResend {
                Button("Resend verification email") {
                    onResend()
                }
                .buttonStyle(.bordered)
            }
        }
        .transition(.opacity)
    }
}

#Preview {
    VStack(spacing: 16) {
        AuthErrorBlock(message: "Wrong email or password")

        AuthErrorBlock(
            message: "Please verify your email",
            showResend: true
        ) {
            // no operation in preview
        }
    }
    .padding()
}
