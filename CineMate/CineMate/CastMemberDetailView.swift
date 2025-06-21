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
    @Environment(\.isPreview) private var isPreview
    init(member: CastMember, viewModel: PersonViewModel) {
        self.member = member
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AsyncImage(url: member.profileURL) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.gray)
                    }
                }
                .frame(width: 180, height: 180)
                .clipShape(Circle())

                Text(member.name)
                    .font(.title)
                    .bold()

                if let role = member.character {
                    Text("Role: \(role)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                if let detail = viewModel.personDetail {
                    if let birthday = detail.birthday {
                        Text("🎂 Born: \(birthday)")
                    }

                    if let deathday = detail.deathday {
                        Text("🕯️ Died: \(deathday)")
                    }

                    if let place = detail.placeOfBirth {
                        Text("📍 Place of birth: \(place)")
                    }

                    if let bio = detail.biography, !bio.isEmpty {
                        Text(bio)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }

                    HStack(spacing: 16) {
                        if let imdbLink = detail.imdbURL {
                            Link(destination: imdbLink) {
                                Label("IMDb", systemImage: "link")
                            }
                        }

                        if let tmdbLink = detail.tmdbURL {
                            Link(destination: tmdbLink) {
                                Label("TMDB", systemImage: "film")
                            }
                        }

                        if let tmdbLink = detail.tmdbURL {
                            ShareLink(item: tmdbLink) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        }
                    }
                    .padding(.top)
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
            if !isPreview {
                await viewModel.loadPersonDetail(for: member.id)
            }
        }
    }
}

#Preview("Cast Detail – Mark Hamill") {
    CastMemberDetailView.markHamillPreview
}
