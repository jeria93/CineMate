//
//  FavoritePeopleGrid.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-12.
//

import SwiftUI

struct FavoritePeopleGrid: View {
    @ObservedObject var viewModel: FavoritePeopleViewModel
    @EnvironmentObject private var navigator: AppNavigator

    private let cols = [GridItem(.adaptive(minimum: 110), spacing: 12)]

    var body: some View {
        if viewModel.favorites.isEmpty {
            EmptyStateView(systemImage: "person", title: "No favorite people",
                           message: "Tap the heart on a person")
        } else {
            ScrollView {
                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(viewModel.favorites) { person in
                        VStack(spacing: 8) {
                            AsyncImage(url: person.profileSmallURL) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFill()
                                }
                                else {
                                    Color.gray
                                        .opacity(0.2)
                                        .overlay(
                                            Image(systemName: "person")
                                                .font(.largeTitle)
                                        )
                                }
                            }
                            .frame(width: 110, height: 150)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 12,
                                    style: .continuous
                                )
                            )

                            Text(person.name)
                                .font(.footnote)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                        .onTapGesture { navigator.goToPerson(id: person.id) }
                    }
                }
                .padding()
            }
        }
    }
}

#Preview("Few") {
    FavoritePeopleGrid.previewFew.withPreviewNavigation()
}

#Preview("Many") {
    FavoritePeopleGrid.previewMany.withPreviewNavigation()
}

#Preview("Empty") {
    FavoritePeopleGrid.previewEmpty.withPreviewNavigation()
}
