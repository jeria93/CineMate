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
        VStack(spacing: 16) {
            Text("Reset password")
                .font(.title3).bold()
                .frame(maxWidth: .infinity, alignment: .leading)

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

            Button { Task { await handleSend() } } label: {
                Text("Send reset link").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isSending)

            Button("Cancel") { dismiss() }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
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
