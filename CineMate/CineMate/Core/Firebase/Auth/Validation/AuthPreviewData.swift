//
//  AuthPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-16.
//

import Foundation

/// **AuthPreviewData**
/// Lightweight preview scaffolding for auth UI.
/// Provides static demo values, latency presets, and a tiny config to shape preview scenarios
/// (signed out/in, failure, and busy states).
enum AuthPreviewData {

    /// Demo UID used to simulate a signed-in state in previews.
    static let demoUID  = "DEMO01"

    /// Human-readable error message for failed sign-in previews.
    static let errorText = "Simulated auth failure error"

    /// Common nanosecond delays to mimic network latency in previews.
    enum DelayNs {
        /// ~150ms – instant UI feedback.
        static let veryShort: UInt64 = 150_000_000
        /// ~200ms – lightweight actions.
        static let short    : UInt64 = 200_000_000
        /// ~300ms – standard async operation.
        static let medium   : UInt64 = 300_000_000
    }

    /// Small set of knobs to configure a preview scenario.
    struct Config {
        /// Start state: `nil` = signed out, value = signed in.
        var initialUID: String? = nil
        /// If `true`, guest sign-in intentionally fails.
        var willFailOnSignIn = false
        /// Artificial latency used by previews (nanoseconds).
        var delayNs = DelayNs.short
        /// If `true`, the view starts in a “busy” state (spinner visible).
        var initialIsBusy = false
    }
}
