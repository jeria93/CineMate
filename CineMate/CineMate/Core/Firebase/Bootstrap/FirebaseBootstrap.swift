//
//  FirebaseBootstrap.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-08.
//

import Foundation
import FirebaseCore

/// Ensures that Firebase is configured **exactly once**.
///
/// Responsibilities
/// 1. Call `FirebaseApp.configure()` a single time.
/// 2. Hide FirebaseCore from the rest of the codebase.
///
/// Usage
/// ```swift
/// @main
/// struct CineMate: App {
///     init() { FirebaseBootstrap.ensureConfigured() }
///     var body: some Scene { … }
/// }
/// ```
enum FirebaseBootstrap {

    /// Indicates whether Firebase has already been configured.
    private static var isFirebaseConfigured = false

    /// Idempotent bootstrap entry point.
    static func ensureConfigured() {
        guard !isFirebaseConfigured else { return }
        FirebaseApp.configure()
        isFirebaseConfigured = true
    }
}
