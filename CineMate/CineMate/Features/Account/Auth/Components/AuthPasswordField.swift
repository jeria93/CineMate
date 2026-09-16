//
//  AuthPasswordField.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-26.
//

import SwiftUI

struct AuthPasswordField: View {
    enum Mode { case login, create }

    var title: String = "Password"
    @Binding var text: String
    var isDisabled: Bool = false
    var mode: Mode = .login
    var submitLabel: SubmitLabel = .next
    var onSubmit: () -> Void = {}
    var onCleared: () -> Void = {}
    var isFocused: FocusState<Bool>.Binding?

    @State private var isRevealed = false

    var body: some View {
        RoundedField(icons: trailingIcons) {
            passwordField
                .submitLabel(submitLabel)
                .onSubmit(onSubmit)
                .applyFocus(isFocused)
                .disabled(isDisabled)
        }
    }
}

private extension AuthPasswordField {
    var hasText: Bool { !text.isEmpty }

    var revealIconName: String { isRevealed ? "eye.slash.fill" : "eye.fill" }

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

    @ViewBuilder
    var passwordField: some View {
        if isRevealed {
            TextField(title, text: $text).applyContentType(mode: mode)
        } else {
            SecureField(title, text: $text).applyContentType(mode: mode)
        }
    }
}

private extension View {
    @ViewBuilder
    func applyContentType(mode: AuthPasswordField.Mode) -> some View {
        let baseInputPolicy = self
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
