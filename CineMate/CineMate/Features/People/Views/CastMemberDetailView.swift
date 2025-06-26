//
//  CastMemberDetailView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import SwiftUI

struct CastMemberDetailView: View {
    let member: CastMember
    @StateObject private var viewModel: PersonViewModel

    init(member: CastMember, viewModel: PersonViewModel) {
        self.member = member
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CastMemberImageView(url: member.profileURL)
                    .padding(.top, 16)

                Text(member.name)
                    .font(.title)
                    .bold()

                if let role = member.character {
                    Text("Role: \(role)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                if let detail = viewModel.personDetail {
                    PersonInfoView(detail: detail)
                    PersonLinksView(imdbURL: detail.imdbURL, tmdbURL: detail.tmdbURL)
                }

                if !viewModel.personMovies.isEmpty {
                    HorizontalMoviesScrollView(filmography
: viewModel.personMovies)
                }

                if viewModel.isLoading {
                    ProgressView("Loading...")
                }

                if let error = viewModel.errorMessage {
                    Text("Error: \(error)").foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadData() }
    }

    private func loadData() async {
        debugPrint("Loading personId = \(member.id)")
        await viewModel.loadPersonDetail(for: member.id)
        await viewModel.loadPersonMovieCredits(for: member.id)
        debugPrint("personDetail = \(String(describing: viewModel.personDetail))")
        debugPrint("personMovies count = \(viewModel.personMovies.count)")
    }
}

#Preview("Default") {
    PreviewFactory.castMemberDetailView()
}
