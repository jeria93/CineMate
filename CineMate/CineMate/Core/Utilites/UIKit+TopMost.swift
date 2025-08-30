//
//  UIKit+TopMost.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-29.
//

import UIKit

/// Helper to find the view controller that is currently visible,
/// so you can safely present new UI from anywhere (e.g. from a view model or SwiftUI).
///
/// How it works (best-effort):
/// 1) Uses the active foreground scene
/// 2) Picks the key window (or first window as fallback)
/// 3) Walks through any presented view controllers
/// 4) Unwraps common containers (navigation/tab)
///
/// May return `nil` during app launch or if there is no active window.
/// Always call on the main thread (this extension is `@MainActor`).
@MainActor
extension UIViewController {

    /// Returns the currently visible view controller in the active scene (best-effort).
    ///
    /// - Returns: The top-most `UIViewController`, or `nil` if none could be found.
    ///
    /// - Example:
    /// ```swift
    /// if let presenter = UIViewController.topMostViewController {
    ///     presenter.present(myVC, animated: true)
    /// }
    /// ```
    static var topMostViewController: UIViewController? {
        // Active foreground scene
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }

        // Key window (fallback to first)
        let window = scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first
        guard var top = window?.rootViewController else { return nil }

        // Follow any presented chain
        while let presented = top.presentedViewController { top = presented }

        // Unwrap common containers
        if let nav = top as? UINavigationController {
            top = nav.visibleViewController ?? nav
        } else if let tab = top as? UITabBarController {
            top = tab.selectedViewController ?? tab
        }

        return top
    }
}
