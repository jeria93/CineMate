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
    private static let lock = NSLock()
    
    /// Idempotent entry point – safe to call multiple times.
    /// - Skips work in previews.
    static func ensureConfigured() {
        guard !ProcessInfo.processInfo.isPreview else { return }
        
        lock.lock()
        defer { lock.unlock() }
        
        guard !isFirebaseConfigured else {
            log("skipped (already configured)")
            return
        }
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            log("configured")
        } else {
            log("detected preconfigured FirebaseApp")
        }
        
        isFirebaseConfigured = true
    }
    
    private static func log(_ message: String) {
#if DEBUG
        print("[App][Bootstrap][Firebase] \(message)")
#endif
    }
}
