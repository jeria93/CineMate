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

                HStack(spacing: 12) {
                    Text(member.name)
                        .font(.title)
                        .bold()

                    FavoriteButton(
                        isFavorite: viewModel.isFavoriteCast(id: member.id),
                        toggleAction: {
                            viewModel.toggleFavoriteCast(id: member.id)
                        }
                    )
                }

                if let role = member.character {
                    Text("Role: \(role)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                if let detail = viewModel.personDetail {
                    SectionHeader(title: "Biography")
                    PersonInfoView(detail: detail)

                    SectionHeader(title: "Links")
                    PersonLinksView(imdbURL: detail.imdbURL, tmdbURL: detail.tmdbURL)

                    SectionHeader(title: "Details")
                    PersonMetaInfoView(detail: detail)
                }

                // "Most Iconic Roles" (Known For)
                if !viewModel.knownForMovies.isEmpty {
                    KnownForScrollView(movies: viewModel.knownForMovies)
                }

                if !viewModel.personMovies.isEmpty {
                    SectionHeader(title: "Filmography")
                    HorizontalMoviesScrollView(filmography: viewModel.personMovies)
                }

                if viewModel.isLoading {
                    ProgressView("Loading...")
                }

                if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadData() }
    }
}

#Preview("Default") {
    PreviewFactory.castMemberDetailView()
}

private extension CastMemberDetailView {
    private func loadData() async {
        debugPrint("Loading personId = \(member.id)")
        await viewModel.loadPersonDetail(for: member.id)
        await viewModel.loadPersonMovieCredits(for: member.id)
        debugPrint("personDetail = \(String(describing: viewModel.personDetail))")
        debugPrint("personMovies count = \(viewModel.personMovies.count)")
    }
}
