//
//  ToastBanner.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-22.
//

import SwiftUI

/// Small visual toast banner used by the `toast(_:)` view modifier.
/// Lightweight UI only; no timers or state here.
private struct ToastBanner: View {
    let text: String   // message to display

    var body: some View {
        Text(text)
            .font(.footnote).bold()
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(radius: 1)
            .transition(.move(edge: .top).combined(with: .opacity))
            .padding(.top, 8)
    }
}

extension View {
    /// Overlays a top toast when `message` is non-nil.
    /// Use with `ToastCenter` like: `.toast(toastCenter.message)`.
    func toast(_ message: String?) -> some View {
        ZStack(alignment: .top) {
            self
            if let msg = message {
                ToastBanner(text: msg)   // render banner when a message exists
            }
        }
        // animate show/hide when message appears/disappears
        .animation(.spring(response: 0.32, dampingFraction: 0.9), value: message != nil)
    }
}

/// Simple toast state holder for the app.
/// Stores a single message and clears it after a short delay.
@MainActor
final class ToastCenter: ObservableObject {
    @Published var message: String?   // current toast text (nil = hidden)

    /// Shows a toast for `duration` seconds, then hides it.
    /// If another toast arrives, we avoid clearing the newer one.
    func show(_ text: String, duration: TimeInterval = 3) {
        message = text
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard let self else { return }
            // only clear if unchanged (prevents clearing a newer toast)
            if self.message == text { self.message = nil }
        }
    }
}
