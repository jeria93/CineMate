//
//  FeatureGate.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-31.
//

import Foundation

/// # FeatureGate
/// Tiny helper for gating features that require a **full account**.
/// If the current user is a guest, it **shows a toast** and returns `false`.
///
/// Use this to keep your views simple:
/// call the gate right before you perform an action (e.g. submit search, save favorite).
@MainActor
enum FeatureGate {

    /// Requires a full account for the given feature.
    ///
    /// If the current user is a **guest**, this:
    /// 1) shows a toast like _“Create a free account to use {feature}”_;
    /// 2) returns `false` so the caller can early-return.
    ///
    /// If the user is **not** a guest, it returns `true`.
    ///
    /// - Parameters:
    ///   - name: Human-readable feature name shown in the toast (e.g. `"Search"`, `"Favorites"`).
    ///   - auth: Source of truth for guest/real account status.
    ///   - toast: Toast center used to display the nudge.
    /// - Returns: `true` if the action is allowed; `false` if blocked due to guest.
    ///
    /// - Note: Runs on the **main actor**, so you can call it directly from UI actions.
    ///
    /// ## Example
    /// ```swift
    /// guard FeatureGate.requireFullAccount(feature: "Search", auth: authVM, toast: toastCenter) else { return }
    /// await viewModel.search(query)
    /// ```
    static func requireFullAccount(feature name: String, auth: AuthViewModel, toast: ToastCenter) -> Bool {
        guard !auth.isGuest else {
            toast.show("Create a free account to use \(name)")
            return false
        }
        return true
    }
}
