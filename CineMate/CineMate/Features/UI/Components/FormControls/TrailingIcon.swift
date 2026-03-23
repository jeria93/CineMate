//
//  TrailingIcon.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-23.
//

import SwiftUI

/// A small value type that describes one trailing action icon.
///
/// Use this to add quick actions on the right side of a field,
/// such as clearing text or toggling password visibility.
///
/// - Parameters:
///   - systemName: SF Symbol name to display.
///   - isEnabled: Whether the icon is tappable. Disabled icons are dimmed.
///   - accessibilityLabel: Optional label for VoiceOver. Defaults to `systemName`.
///   - action: Closure executed on tap.
///
/// ### Example
/// ```swift
/// TrailingIcon(systemName: "eye.fill",
///              isEnabled: true,
///              accessibilityLabel: "Show password") {
///     showPassword.toggle()
/// }
/// ```
struct TrailingIcon: Identifiable {
    let id: String
    let systemName: String
    var isEnabled: Bool = true
    var accessibilityLabel: String?
    let action: () -> Void

    init(
        id: String? = nil,
        systemName: String,
        isEnabled: Bool = true,
        accessibilityLabel: String? = nil,
        action: @escaping () -> Void
    ) {
        self.id = id ?? systemName
        self.systemName = systemName
        self.isEnabled = isEnabled
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }
}
