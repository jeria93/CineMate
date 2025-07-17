//
//  PersonMetaInfoView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

/// Preview variations for `PersonMetaInfoView`.
///
/// Simulates full, empty, and partial data states.
extension PersonMetaInfoView {

    /// Preview with full person detail (e.g. Mark Hamill).
    static var previewFull: some View {
        PersonMetaInfoView(detail: PersonMetaInfoPreviewData.full)
            .padding()
            .background(Color(.systemBackground))
    }

    /// Preview with completely empty meta info.
    static var previewEmpty: some View {
        PersonMetaInfoView(detail: PersonMetaInfoPreviewData.empty)
            .padding()
            .background(Color(.systemBackground))
    }

    /// Preview with partial data (e.g. only gender).
    static var previewPartial: some View {
        PersonMetaInfoView(detail: PersonMetaInfoPreviewData.partial)
            .padding()
            .background(Color(.systemBackground))
    }
}
