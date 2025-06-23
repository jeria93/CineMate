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
                    PersonMoviesView(movies: viewModel.personMovies)
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
        .navigationTitle(member.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadPersonDetail(for: member.id)
            await viewModel.loadPersonMovieCredits(for: member.id)
        }
    }
}

#Preview("Cast Detail – Mark Hamill") {
    CastMemberDetailView.preview
}


