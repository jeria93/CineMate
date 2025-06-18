//
//  PreviewStyle.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-18.
//

import SwiftUI

/// A custom view modifier used for styling SwiftUI previews.
/// Applies padding and a system background color to make previews consistent and visually clean.
struct PreviewBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
    }
}

extension View {
    func previewStyle() -> some View {
        self.modifier(PreviewBackground())
    }
}
/// A convenience method for applying standardized preview styling.
///
/// Use this in your preview declarations to ensure consistent layout
/// and background color across all component previews.
///
/// Example:
/// ```swift
/// MyCustomView()
///     .previewStyle()
/// ```
///
/// - Returns: The modified view with `PreviewBackground` applied.
