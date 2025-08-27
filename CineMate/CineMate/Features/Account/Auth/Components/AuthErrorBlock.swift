//
//  AuthErrorBlock.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-26.
//

import SwiftUI

/// Small error block for auth flows.
/// Displays a red error message and (optionally) a **Resend verification email** action.
///
/// - Requires: A `ToastCenter` in the environment **iff** `showResend == true`
///   (used to show a success toast after `onResend()`).
///
/// ### Example
/// ```swift
/// AuthErrorBlock(
///     message: "Please verify your email",
///     showResend: true
/// ) {
///     await authVM.resendVerification()
/// }
/// .environmentObject(ToastCenter())
/// ```
struct AuthErrorBlock: View {

    /// Error text shown to the user.
    let message: String

    /// If `true`, renders the "Resend verification email" button.
    var showResend: Bool = false

    /// Called when the user taps **Resend**.
    /// Your handler should trigger the resend operation.
    var onResend: () -> Void = {}

    @EnvironmentObject private var toastCenter: ToastCenter

    var body: some View {
        VStack(spacing: 8) {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)

            if showResend {
                Button("Resend verification email") {
                    onResend()
                    toastCenter.show("Verification email sent. Check your inbox")
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
    .withPreviewToasts() // injects ToastCenter for the preview
}
