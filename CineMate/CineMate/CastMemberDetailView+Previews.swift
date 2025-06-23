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
                member: PreviewData.markHamill,
                viewModel: viewModel
            )
        }
    }

    static var preview: some View {
        CastMemberDetailView(
            member: PreviewData.markHamill,
            viewModel: .preview
        )
    }
}
