//
//  Environment+Preview.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import SwiftUI

private struct IsPreviewKey: EnvironmentKey {
    static let defaultValue: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}

extension EnvironmentValues {
    var isPreview: Bool {
        self[IsPreviewKey.self]
    }
}
