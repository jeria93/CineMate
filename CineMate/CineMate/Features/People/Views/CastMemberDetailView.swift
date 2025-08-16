//
//  CastMemberDetailView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-22.
//

import SwiftUI

struct CastMemberDetailView: View {
    let member: CastMember
    @ObservedObject var personViewModel: PersonViewModel
    @ObservedObject var favoritePeopleVM: FavoritePeopleViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CastMemberImageView(
                    url: personViewModel.personDetail?.profileURL ?? member.profileURL
                )
                .padding(.top, 16)
                
                HStack(spacing: 12) {
                    Text(personViewModel.personDetail?.name ?? member.name)
                        .font(.title)
                        .bold()
                    
                    HeartButton(isOn: favoritePeopleVM.isFavorite(id: member.id)) {
                        let name = personViewModel.personDetail?.name ?? member.name
                        let path = personViewModel.personDetail?.profilePath ?? member.profilePath
                        let ref = PersonRef(id: member.id, name: name, profilePath: path)
                        Task { await favoritePeopleVM.toggleFavorite(person: ref) }
                    }
                }
                
                if let role = personViewModel.personDetail?.knownForDepartment ?? member.character {
                    Text("Role: \(role)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                if let detail = personViewModel.personDetail {
                    SectionHeader(title: "Biography")
                    PersonInfoView(detail: detail)
                    
                    SectionHeader(title: "Links")
                    PersonLinksView(
                        imdbURL: detail.imdbURL,
                        tmdbURL: detail.tmdbURL,
                        instagramURL: personViewModel.personExternalIDs?.instagramURL,
                        twitterURL: personViewModel.personExternalIDs?.twitterURL,
                        facebookURL: personViewModel.personExternalIDs?.facebookURL
                    )
                    
                    SectionHeader(title: "Details")
                    PersonMetaInfoView(detail: detail)
                }
                
                if !personViewModel.knownForMovies.isEmpty {
                    KnownForScrollView(movies: personViewModel.knownForMovies, movieViewModel: nil)
                }
                
                if !personViewModel.personMovies.isEmpty {
                    SectionHeader(title: "Filmography")
                    HorizontalMoviesScrollView(filmography: personViewModel.personMovies)
                }
                
                if let error = personViewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if personViewModel.isLoading {
                LoadingView(title: "Loading…")
                    .scaleEffect(1.3)
                    .padding(32)
                    .background(.ultraThinMaterial,
                                in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .task(id: member.id) {
            personViewModel.resetForNewPerson()
            
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await personViewModel.loadPersonDetail(for: member.id) }
                group.addTask { await personViewModel.loadPersonMovieCredits(for: member.id) }
            }
        }
        .onAppear {
            print("[CastMemberDetailView] appeared for member id:", member.id)
        }
        .onDisappear {
            personViewModel.cancelOngoingTasks(for: member.id)
        }
    }
}

#Preview("Default") {
    PreviewFactory.castMemberDetailView()
}
