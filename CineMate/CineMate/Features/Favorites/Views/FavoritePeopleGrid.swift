//
//  FavoritePeopleGrid.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-12.
//

import SwiftUI

struct FavoritePeopleGrid: View {
    @ObservedObject var viewModel: FavoritePeopleViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.favorites, id: \.id) { person in
                    PersonCardView(person: person)
                }
            }
            .padding()
        }
        .overlay {
            if viewModel.isLoading {
                LoadingView(title: "Loading favorites...")
            } else if let error = viewModel.errorMessage {
                ErrorMessageView(title: "Error", message: error)
            } else if viewModel.favorites.isEmpty {
                EmptyStateView(
                    systemImage: "star",
                    title: "No Favorites Yet",
                    message: "People you add to favorites will appear here."
                )
            }
        }
    }
}

#Preview("Few") {
    FavoritePeopleGrid.previewFew
}

#Preview("Many") {
    FavoritePeopleGrid.previewMany
}

#Preview("Empty") {
    FavoritePeopleGrid.previewEmpty
}
