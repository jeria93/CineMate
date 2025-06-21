//
//  CastMemberDetailView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import SwiftUI

extension CastMemberDetailView {
    static var markHamillPreview: some View {
        NavigationStack {
            CastMemberDetailView(member: PreviewData.starWarsCredits.cast[0])
        }
    }
}
