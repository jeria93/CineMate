//
//  CastMemberDetailView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-22.
//

import SwiftUI

struct CastMemberDetailView: View {
    let member: CastMember
    @ObservedObject var viewModel: PersonViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CastMemberImageView(
                    url: viewModel.personDetail?.profileURL ?? member.profileURL
                )
                .padding(.top, 16)
                
                HStack(spacing: 12) {
                    Text(viewModel.personDetail?.name ?? member.name)
                        .font(.title)
                        .bold()
                    
                    HeartButton(isOn: viewModel.isFavoriteCast(id: member.id)) {
                        viewModel.toggleFavoriteCast(id: member.id)
                    }
                }
                
                if let role = viewModel.personDetail?.knownForDepartment ?? member.character {
                    Text("Role: \(role)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                if let detail = viewModel.personDetail {
                    SectionHeader(title: "Biography")
                    PersonInfoView(detail: detail)
                    
                    SectionHeader(title: "Links")
                    PersonLinksView(
                        imdbURL: detail.imdbURL,
                        tmdbURL: detail.tmdbURL,
                        instagramURL: viewModel.personExternalIDs?.instagramURL,
                        twitterURL: viewModel.personExternalIDs?.twitterURL,
                        facebookURL: viewModel.personExternalIDs?.facebookURL
                    )
                    
                    SectionHeader(title: "Details")
                    PersonMetaInfoView(detail: detail)
                }
                
                if !viewModel.knownForMovies.isEmpty {
                    KnownForScrollView(movies: viewModel.knownForMovies, movieViewModel: nil)
                }
                
                if !viewModel.personMovies.isEmpty {
                    SectionHeader(title: "Filmography")
                    HorizontalMoviesScrollView(filmography: viewModel.personMovies)
                }
                
                if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isLoading {
                LoadingView(title: "Loading…")
                    .scaleEffect(1.3)
                    .padding(32)
                    .background(.ultraThinMaterial,
                                in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .task(id: member.id) {
            viewModel.resetForNewPerson()
            
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await viewModel.loadPersonDetail(for: member.id) }
                group.addTask { await viewModel.loadPersonMovieCredits(for: member.id) }
            }
        }
        .onAppear {
            print("[CastMemberDetailView] appeared for member id:", member.id)
        }
        .onDisappear {
            viewModel.cancelOngoingTasks(for: member.id)
        }
    }
}

#Preview("Default") {
    PreviewFactory.castMemberDetailView()
}
