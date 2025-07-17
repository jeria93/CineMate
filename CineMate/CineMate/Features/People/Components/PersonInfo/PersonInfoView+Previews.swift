//
//  PersonInfoView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-29.
//

import SwiftUI

/// Preview variations for `PersonInfoView`.
///
/// Simulates full, empty, and partial data scenarios.
extension PersonInfoView {
    
    /// Preview with full data (e.g., Mark Hamill).
    static var previewMarkHamill: some View {
        PersonInfoView(detail: PersonInfoPreviewData.markHamill)
            .padding()
            .background(Color(.systemBackground))
    }
    
    /// Preview with no available data (empty state).
    static var previewEmpty: some View {
        PersonInfoView(detail: PersonInfoPreviewData.empty)
            .padding()
            .background(Color(.systemBackground))
    }
    
    /// Preview with partial data (e.g., birthday but no bio).
    static var previewPartial: some View {
        PersonInfoView(detail: PersonInfoPreviewData.partial)
            .padding()
            .background(Color(.systemBackground))
    }
}
