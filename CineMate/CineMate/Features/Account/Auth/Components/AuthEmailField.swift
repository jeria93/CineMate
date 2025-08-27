//
//  AuthEmailField.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-26.
//

import SwiftUI

struct AuthEmailField: View {
    var title: String = "Email"
    @Binding var text: String
    var isDisabled: Bool = false
    var submitLabel: SubmitLabel = .next
    var onSubmit: () -> Void = {}
    var onCleared: () -> Void = {}
    var isFocused: FocusState<Bool>.Binding?

    var body: some View {
        RoundedField(icons: icons) {
            TextField(title, text: $text)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .submitLabel(submitLabel)
                .onSubmit(onSubmit)
                .onChange(of: text) { _, new in
                    let cleaned = AuthValidator.sanitizedEmail(from: new)
                    if cleaned != new { text = cleaned }
                }
                .applyFocus(isFocused)
        }
        .disabled(isDisabled)
    }
}

#Preview {
    VStack(spacing: 12) {
        AuthEmailField(text: .constant("user@example.com"))
        AuthEmailField(text: .constant(""), isDisabled: true)
    }
    .padding()
}

// MARK: - Internal helpers
private extension AuthEmailField {
    var hasText: Bool { !text.isEmpty }

    /// Clear icon appears only when enabled and non-empty.
    var icons: [TrailingIcon] {
        guard hasText && !isDisabled else { return [] }
        return [
            TrailingIcon(systemName: "xmark.circle.fill") {
                text = ""
                onCleared()
            }
        ]
    }
}
