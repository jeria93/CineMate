//
//  CastMemberView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-18.
//

import SwiftUI

extension CastMemberView {
    static var markHamill: some View {
        CastMemberView(
            member: PreviewData.markHamill,
            repository: PreviewFactory.repository
        )
    }

    static var unknownActor: some View {
        CastMemberView(
            member: PreviewData.unknownActor,
            repository: PreviewFactory.repository
        )
    }

    static var longName: some View {
        CastMemberView(
            member: PreviewData.longNameActor,
            repository: PreviewFactory.repository
        )
    }
}
