//
//  FirebaseBootstrap.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-08.
//

import Foundation
import FirebaseCore

/// Small guard that configures Firebase **once** at app launch.
/// Skips Xcode Previews to avoid accidental SDK boot during design time.
enum FirebaseBootstrap {

    /// Tracks if Firebase has been configured already (process-wide).
    private static var isFirebaseConfigured = false

    /// Idempotent entry point – safe to call multiple times.
    /// - Skips work in previews.
    static func ensureConfigured() {
        guard !ProcessInfo.processInfo.isPreview else { return }
        guard !isFirebaseConfigured else { return }
        FirebaseApp.configure()
        isFirebaseConfigured = true
    }
}
