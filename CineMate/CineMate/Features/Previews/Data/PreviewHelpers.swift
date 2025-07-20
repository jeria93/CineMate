//
//  PreviewHelpers.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-20.
//

import SwiftUI

/**
 PreviewHelpers
 --------------
 `withPreviewNavigation()`
 A one-liner for previews that need an `AppNavigator`.

 • Creates an isolated navigator (`AppNavigator()`)
 • Wraps the view in a `NavigationStack` so swipe-back works
 • Injects the navigator with `.environmentObject(nav)`

 Use it whenever the previewed view (or a child) expects
 `@EnvironmentObject var navigator: AppNavigator`.
 */
extension View {
    /// Wraps `self` in a `NavigationStack` and injects a fresh navigator.
    func withPreviewNavigation() -> some View {
        let nav = AppNavigator()          // 1. isolated GPS
        return NavigationStack { self }   // 2. optional stack for gestures
            .environmentObject(nav)       // 3. inject into the environment
    }
}
