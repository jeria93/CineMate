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
        guard let root = activeWindow?.rootViewController else { return nil }
        return resolveTopMost(from: root)
    }

    private static var activeWindow: UIWindow? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }

        let preferredScene = scenes.first { $0.activationState == .foregroundActive }
            ?? scenes.first { $0.activationState == .foregroundInactive }
            ?? scenes.first

        let windows = preferredScene?.windows ?? []
        return windows.first(where: \.isKeyWindow) ?? windows.first
    }

    private static func resolveTopMost(from viewController: UIViewController) -> UIViewController {
        if let presented = viewController.presentedViewController {
            return resolveTopMost(from: presented)
        }

        if let navigation = viewController as? UINavigationController {
            let next = navigation.visibleViewController ?? navigation.topViewController ?? navigation
            return resolveTopMost(from: next)
        }

        if let tab = viewController as? UITabBarController {
            let next = tab.selectedViewController ?? tab
            return resolveTopMost(from: next)
        }

        if let split = viewController as? UISplitViewController,
           let last = split.viewControllers.last {
            return resolveTopMost(from: last)
        }

        return viewController
    }
}
