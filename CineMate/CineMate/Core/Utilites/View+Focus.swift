//
//  View+Focus.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-26.
//

import SwiftUI

extension View {
    /// Applies `.focused` only if a binding exists.
    @ViewBuilder
    func applyFocus(_ binding: FocusState<Bool>.Binding?) -> some View {
        if let binding { self.focused(binding) } else { self }
    }
}
