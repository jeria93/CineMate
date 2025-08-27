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

// MARK: - Internals (private helpers)
private extension AuthPasswordField {
    var hasText: Bool { !text.isEmpty }

    var revealIconName: String { isRevealed ? "eye.slash.fill" : "eye.fill" }

    /// Trailing icons (clear + reveal) when enabled and non-empty.
    var trailingIcons: [TrailingIcon] {
        guard hasText && !isDisabled else { return [] }
        return [clearIcon, revealIcon]
    }

    var clearIcon: TrailingIcon {
        TrailingIcon(systemName: "xmark.circle.fill") {
            text = ""
            onCleared()
        }
    }

    var revealIcon: TrailingIcon {
        TrailingIcon(systemName: revealIconName) {
            isRevealed.toggle()
        }
    }

    /// Chooses between `TextField` and `SecureField` based on `isRevealed`.
    @ViewBuilder
    var passwordField: some View {
        if isRevealed {
            TextField(title, text: $text).applyContentType(mode: mode)
        } else {
            SecureField(title, text: $text).applyContentType(mode: mode)
        }
    }
}

// MARK: - Content type / keyboard policy
private extension View {
    /// Applies contentType/keyboard for the given `AuthPasswordField.Mode`.
    @ViewBuilder
    func applyContentType(mode: AuthPasswordField.Mode) -> some View {
        switch mode {
        case .login:
            self.textContentType(.password)
        case .create:
            self
                .textContentType(nil)
                .keyboardType(.asciiCapable)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
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
