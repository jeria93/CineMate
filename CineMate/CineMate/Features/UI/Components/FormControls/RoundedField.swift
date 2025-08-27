//
//  RoundedField.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-23.
//

import SwiftUI

/// A rounded input container that mimics the look of `.roundedBorder`.
///
/// `RoundedField` draws its own background and border and can show
/// optional **trailing action icons** (for example: *clear*, *show/hide password*).
///
/// - Important: Pass a plain `TextField`/`SecureField` as `content`.
///   Do **not** apply another text field style inside; this view renders the frame.
///
/// ### Example
/// ```swift
/// @State private var email = ""
///
/// RoundedField(icons: email.isEmpty ? [] : [
///     TrailingIcon(systemName: "xmark.circle.fill") { email = "" }
/// ]) {
///     TextField("Email", text: $email)
/// }
/// ```
struct RoundedField<Content: View>: View {
    /// Icons shown on the trailing (right) edge of the field.
    let icons: [TrailingIcon]

    /// The input view (e.g., `TextField` or `SecureField`) to render inside.
    @ViewBuilder var content: () -> Content

    /// Creates a rounded field.
    ///
    /// - Parameters:
    ///   - icons: Action icons to display on the trailing side. Defaults to `[]` (no icons).
    ///   - content: The input view to render inside the field.
    init(icons: [TrailingIcon] = [], @ViewBuilder content: @escaping () -> Content) {
        self.icons = icons
        self.content = content
    }

    // Tuned constants to match iOS text field visuals.
    private let cornerRadius: CGFloat = 8
    private let horizontalPadding: CGFloat = 12
    private let verticalPadding: CGFloat = 10
    private let trailingInset: CGFloat = 6
    private let interIconSpacing: CGFloat = 6
    private let minHeight: CGFloat = 44

    var body: some View {
        ZStack(alignment: .trailing) {
            // Content without its own border: we draw the container ourselves.
            content()
                .textFieldStyle(.plain)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .frame(minHeight: minHeight, alignment: .center)

            // Trailing icons inside the same visual box.
            if !icons.isEmpty {
                HStack(spacing: interIconSpacing) {
                    ForEach(icons) { RoundedFieldIconButton(icon: $0) }
                }
                .padding(.trailing, trailingInset)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

/// Private button used by `RoundedField` to render each trailing icon.
///
/// - Note: Keeps hit area, color, and layout consistent across fields.
private struct RoundedFieldIconButton: View {
    let icon: TrailingIcon
    private let tapTargetSize: CGFloat = 32
    private let symbolPointSize: CGFloat = 18

    var body: some View {
        Button(action: icon.action) {
            Image(systemName: icon.systemName)
                .font(.system(size: symbolPointSize, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
                .frame(width: tapTargetSize, height: tapTargetSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!icon.isEnabled)
        .opacity(icon.isEnabled ? 1 : 0.4)
        .accessibilityLabel(icon.accessibilityLabel ?? icon.systemName)
    }
}
