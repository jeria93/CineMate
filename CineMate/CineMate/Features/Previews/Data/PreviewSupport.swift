//
//  PreviewSupport.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-10.
//

import Foundation

/// Adds support for detecting if the current code is running in Xcode Previews.
/// Use this utility to skip network calls, timers, or any runtime logic that shouldn't run in previews.
extension ProcessInfo {

    /// Returns `true` if the current process is running in Xcode SwiftUI preview canvas.
    var isPreview: Bool {
        environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
