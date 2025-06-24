//
//  CastMemberDetailView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import SwiftUI

extension CastMemberDetailView {
    static var preview: some View {
        NavigationStack {
            CastMemberDetailView(
                member: PreviewData.markHamill,
                viewModel: PreviewFactory.personViewModel()
            )
        }
    }
}
