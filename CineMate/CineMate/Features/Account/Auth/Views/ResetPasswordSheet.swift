//
//  ResetPasswordSheet.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-24.
//

import SwiftUI

struct ResetPasswordSheet: View {
    // MARK: - Dependencies
    @StateObject private var viewModel: ResetPasswordViewModel
    @EnvironmentObject private var toastCenter: ToastCenter
    @Environment(\.dismiss) private var dismiss

    // MARK: - Focus
    @FocusState private var emailFocused: Bool

    // MARK: - Init
    init() {
        _viewModel = StateObject(
            wrappedValue: ResetPasswordViewModel(
                service: FirebaseAuthService(),
                onResetSent: { _ in }
            )
        )
    }
    init(viewModel: ResetPasswordViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AuthTheme.curtainTop, AuthTheme.curtainBottom],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 64, height: 64)
                            .overlay(Circle().strokeBorder(AuthTheme.cardStroke))

                        Image(systemName: "lock.rotation")
                            .font(.system(size: 24, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(AuthTheme.iconOnCurtain)
                    }

                    Text("Reset password")
                        .font(.title3.bold())
                        .foregroundStyle(.white)

                    Text("Enter your email to get a reset link")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(.top, 15)

                VStack(alignment: .leading, spacing: 16) {
                    AuthEmailField(
                        text: $viewModel.email,
                        isDisabled: viewModel.isSending,
                        submitLabel: .send,
                        onSubmit: { Task { await handleSend() } },
                        isFocused: $emailFocused
                    )

                    if let helper = viewModel.emailHelperText {
                        ValidationMessageView(message: helper)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if let errorText = viewModel.appError?.errorDescription {
                        ValidationMessageView(message: errorText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task { await handleSend() }
                    } label: {
                        Text("Send reset link")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.pillWhite)
                    .controlSize(.large)
                    .frame(height: 48)
                    .disabled(viewModel.isSending)

                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 8)
            }
            .padding(.bottom, 16)
        }
        .tint(AuthTheme.popcorn)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            emailFocused = true
        }
        .overlay {
            if viewModel.isSending {
                LoadingView(title: "Sending…").transition(.opacity)
            }
        }
        .toast(toastCenter.message)
    }

    // MARK: - Actions
    private func handleSend() async {
        if await viewModel.sendPasswordReset() {
            toastCenter.show("If an account exists, we sent a reset link")
            dismiss()
        }
    }
}

#Preview("Empty") { ResetPasswordSheet.previewEmpty }
#Preview("Filled") { ResetPasswordSheet.previewFilled }
#Preview("Sending") { ResetPasswordSheet.previewSending }
#Preview("Invalid Email") { ResetPasswordSheet.previewInvalidEmail }
#Preview("Server Error") { ResetPasswordSheet.previewServerError }
