//
//  CastMemberView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-18.
//

import SwiftUI

/// Preview variations for `CastMemberView`.
///
/// These simulate different cast members and name formats for layout testing:
/// - `markHamill`: A known actor with full data.
/// - `unknownActor`: A fallback actor with limited data.
/// - `longName`: An edge case with a very long name.
extension CastMemberView {

    /// Preview for a known actor: Mark Hamill.
    static var markHamill: some View {
        CastMemberView(
            member: CastMemberPreviewData.markHamill,
            repository: PreviewFactory.repository
        )
    }

    /// Preview for an unknown actor (e.g., missing data).
    static var unknownActor: some View {
        CastMemberView(
            member: CastMemberPreviewData.unknownActor,
            repository: PreviewFactory.repository
        )
    }

    /// Preview for an actor with an exceptionally long name.
    static var longName: some View {
        CastMemberView(
            member: CastMemberPreviewData.longNameActor,
            repository: PreviewFactory.repository
        )
    }
}
