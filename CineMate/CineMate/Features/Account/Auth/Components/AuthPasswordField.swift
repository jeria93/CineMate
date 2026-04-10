//
//  AuthPasswordField.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-26.
//

import SwiftUI

struct AuthPasswordField: View {
    // MARK: - API
    enum Mode { case login, create }

    var title: String = "Password"
    @Binding var text: String
    var isDisabled: Bool = false
    var mode: Mode = .login
    var submitLabel: SubmitLabel = .next
    var onSubmit: () -> Void = {}
    var onCleared: () -> Void = {}
    var isFocused: FocusState<Bool>.Binding?

    // MARK: - Local UI state
    @State private var isRevealed = false

    // MARK: - Body
    var body: some View {
        RoundedField(icons: trailingIcons) {
            passwordField
                .submitLabel(submitLabel)
                .onSubmit(onSubmit)
                .onChange(of: text) { _, new in
                    let cleaned = AuthValidator.sanitizedPassword(from: new)
                    if cleaned != new { text = cleaned }
                }
                .applyFocus(isFocused)
                .disabled(isDisabled)
        }
    }
}

// MARK: - Helpers
private extension AuthPasswordField {
    var hasText: Bool { !text.isEmpty }

    var revealIconName: String { isRevealed ? "eye.slash.fill" : "eye.fill" }

    /// Shows clear and reveal icons only when text exists.
    var trailingIcons: [TrailingIcon] {
        guard hasText && !isDisabled else { return [] }
        return [clearIcon, revealIcon]
    }

    var clearIcon: TrailingIcon {
        TrailingIcon(
            id: "clear-password",
            systemName: "xmark.circle.fill",
            accessibilityLabel: "Clear password"
        ) {
            text = ""
            onCleared()
        }
    }

    var revealIcon: TrailingIcon {
        TrailingIcon(
            id: "toggle-password-visibility",
            systemName: revealIconName,
            accessibilityLabel: isRevealed ? "Hide password" : "Show password"
        ) {
            isRevealed.toggle()
        }
    }

    /// Uses TextField when revealed and SecureField when hidden.
    @ViewBuilder
    var passwordField: some View {
        if isRevealed {
            TextField(title, text: $text).applyContentType(mode: mode)
        } else {
            SecureField(title, text: $text).applyContentType(mode: mode)
        }
    }
}

// MARK: - Input traits
private extension View {
    /// Applies text traits for each password mode.
    @ViewBuilder
    func applyContentType(mode: AuthPasswordField.Mode) -> some View {
        let baseInputPolicy = self
            .keyboardType(.asciiCapable)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)

        switch mode {
        case .login:
            baseInputPolicy.textContentType(.password)
        case .create:
            baseInputPolicy.textContentType(nil)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        AuthPasswordField(text: .constant("Abc1"), mode: .login, submitLabel: .go)
        AuthPasswordField(title: "Confirm Password",
                          text: .constant("Abc1"),
                          mode: .create)
    }
    .padding()
}
