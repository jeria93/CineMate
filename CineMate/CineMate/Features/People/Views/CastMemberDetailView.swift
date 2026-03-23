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
  let movieViewModel: MovieViewModel?

  init(
    member: CastMember,
    personViewModel: PersonViewModel,
    favoritePeopleVM: FavoritePeopleViewModel,
    movieViewModel: MovieViewModel? = nil
  ) {
    self.member = member
    self.personViewModel = personViewModel
    self.favoritePeopleVM = favoritePeopleVM
    self.movieViewModel = movieViewModel
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        headerSection
        contentSection
      }
      .padding()
    }
    .navigationBarTitleDisplayMode(.inline)
    .task(id: member.id) {
      await reload()
    }
    .onDisappear {
      personViewModel.cancelOngoingTasks(for: member.id)
    }
  }

  @ViewBuilder
  private var contentSection: some View {
    if personViewModel.isLoading && !hasRenderableContent {
      LoadingView(title: "Loading person...")
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 40)
    } else if let error = personViewModel.errorMessage, !hasRenderableContent {
      EmptyStateView(
        systemImage: "person.crop.circle.badge.exclamationmark",
        title: "Failed to load person",
        message: error,
        layout: .inline,
        actionTitle: "Retry",
        onAction: { Task { await reload(forceRefresh: true) } }
      )
    } else {
      personContentSections
    }
  }

  @ViewBuilder
  private var personContentSections: some View {
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
    } else {
      EmptyStateView(
        systemImage: "person.crop.circle.badge.exclamationmark",
        title: "No person details",
        message: "We couldn't load details for this person.",
        layout: .inline,
        actionTitle: "Retry",
        onAction: { Task { await reload(forceRefresh: true) } }
      )
    }

    SectionHeader(title: "Known For")
    KnownForScrollView(
      movies: personViewModel.knownForMovies,
      movieViewModel: movieViewModel
    )

    SectionHeader(title: "Filmography")
    if personViewModel.personMovies.isEmpty {
      Text("No filmography available.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    } else {
      HorizontalMoviesScrollView(
        filmography: personViewModel.personMovies,
        movieViewModel: movieViewModel
      )
    }

    if let error = personViewModel.errorMessage, hasRenderableContent {
      Text(error)
        .font(.footnote)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }
  }

  private var headerSection: some View {
    VStack(spacing: 8) {
      CastMemberImageView(url: displayedProfileURL)
        .padding(.top, 16)

      HStack(spacing: 12) {
        Text(displayedName)
          .font(.title)
          .bold()

        HeartButton(
          isOn: favoritePeopleVM.isFavorite(id: member.id),
          isDisabled: favoritePeopleVM.isToggleInFlight(id: member.id)
        ) {
          Task { await favoritePeopleVM.toggleFavorite(person: personRef) }
        }
      }

      if let displayedRole {
        Text("Role: \(displayedRole)")
          .font(.headline)
          .foregroundStyle(.secondary)
      }
    }
  }

  private var displayedName: String {
    personViewModel.personDetail?.name ?? member.name
  }

  private var displayedProfileURL: URL? {
    personViewModel.personDetail?.profileURL ?? member.profileURL
  }

  private var displayedRole: String? {
    if let department = personViewModel.personDetail?.knownForDepartment {
      if !department.isEmpty {
        return department
      }
    }

    if let character = member.character, !character.isEmpty {
      return character
    }

    return nil
  }

  private var hasRenderableContent: Bool {
    personViewModel.personDetail != nil || !personViewModel.personMovies.isEmpty
  }

  private var personRef: PersonRef {
    let name = personViewModel.personDetail?.name ?? member.name
    let profilePath = personViewModel.personDetail?.profilePath ?? member.profilePath
    return PersonRef(id: member.id, name: name, profilePath: profilePath)
  }

  private func reload(forceRefresh: Bool = false) async {
    await personViewModel.loadPersonProfile(for: member.id, forceRefresh: forceRefresh)
  }
}

#Preview("Default") {
  PreviewFactory.castMemberDetailView()
}
