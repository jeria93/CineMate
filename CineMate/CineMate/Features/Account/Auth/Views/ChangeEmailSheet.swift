//
//  ChangeEmailSheet.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-04-09.
//

import SwiftUI

struct ChangeEmailSheet: View {
    let currentEmail: String?
    let onSubmit: (String) async -> AuthViewModel.ChangeEmailResult
    let onResult: (AuthViewModel.ChangeEmailResult) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var newEmail = ""
    @State private var confirmEmail = ""
    @State private var hasTriedSubmit = false
    @State private var isSubmitting = false
    @State private var cooldownRemainingSeconds = 0

    private var isNewEmailValid: Bool {
        AuthValidator.isValidEmail(newEmail)
    }

    private var isConfirmMatch: Bool {
        !confirmEmail.isEmpty && confirmEmail == newEmail
    }

    private var isSameAsCurrentEmail: Bool {
        guard let currentEmail else { return false }
        return AuthValidator.sanitizedEmail(from: currentEmail) == AuthValidator.sanitizedEmail(from: newEmail)
    }

    private var canSubmit: Bool {
        isNewEmailValid && isConfirmMatch && !isSameAsCurrentEmail && !isSubmitting && cooldownRemainingSeconds == 0
    }

    var body: some View {
        NavigationStack {
            Form {
                if let currentEmail {
                    Section("Current email") {
                        Text(currentEmail)
                            .foregroundStyle(Color.appTextSecondary)
                            .textSelection(.enabled)
                    }
                }

                Section("New email") {
                    TextField("New email", text: $newEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .disabled(isSubmitting)

                    TextField("Confirm new email", text: $confirmEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .disabled(isSubmitting)

                    if (hasTriedSubmit || !newEmail.isEmpty) && !isNewEmailValid {
                        Text(AuthValidator.Message.invalidEmail)
                            .foregroundStyle(.red)
                    }

                    if (hasTriedSubmit || !newEmail.isEmpty) && isSameAsCurrentEmail {
                        Text("New email must be different from current email")
                            .foregroundStyle(.red)
                    }

                    if (hasTriedSubmit || !confirmEmail.isEmpty) && !isConfirmMatch {
                        Text("Emails do not match")
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button("Send verification link") {
                        Task { await submit() }
                    }
                    .disabled(!canSubmit)
                } footer: {
                    if cooldownRemainingSeconds > 0 {
                        Text("Please wait \(cooldownRemainingSeconds) seconds before sending another link.")
                    } else {
                        Text("We send the verification link to your new email address.")
                    }
                }
            }
            .navigationTitle("Change Email")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(isSubmitting)
                }
            }
            .onChange(of: newEmail) { _, newValue in
                let sanitized = sanitizeEmailInput(newValue)
                if sanitized != newValue {
                    newEmail = sanitized
                }
            }
            .onChange(of: confirmEmail) { _, newValue in
                let sanitized = sanitizeEmailInput(newValue)
                if sanitized != newValue {
                    confirmEmail = sanitized
                }
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                guard cooldownRemainingSeconds > 0 else { return }
                cooldownRemainingSeconds -= 1
            }
        }
    }

    @MainActor
    private func submit() async {
        hasTriedSubmit = true
        guard canSubmit else { return }

        isSubmitting = true
        defer { isSubmitting = false }

        let result = await onSubmit(newEmail)
        onResult(result)
        switch result {
        case .verificationSent:
            dismiss()
        case .cooldown(let seconds):
            startCooldown(seconds: seconds)
        default:
            break
        }
    }

    private func sanitizeEmailInput(_ value: String) -> String {
        AuthValidator.sanitizedEmail(from: value).filter(\.isASCII)
    }

    private func startCooldown(seconds: Int) {
        cooldownRemainingSeconds = max(seconds, 1)
    }
}
