//
//  CastMemberDetailView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import SwiftUI

extension CastMemberDetailView {
    static var markHamillPreview: some View {
        let repository = MockMovieRepository()
        let viewModel = PersonViewModel(repository: repository)
        viewModel.personDetail = PreviewData.markHamillPersonDetail

        return NavigationStack {
            CastMemberDetailView(
                member: PreviewData.starWarsCredits.cast.first!,
                viewModel: viewModel
            )
        }
    }
}
