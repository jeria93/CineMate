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
        contentView
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.contentState {
        case .loading:
            LoadingView(title: "Loading favorite people...")

        case .error(let message):
            ErrorMessageView(
                title: "Failed to load favorite people",
                message: message,
                onRetry: { viewModel.retryListener() }
            )

        case .empty:
            EmptyStateView(
                systemImage: "person",
                title: "No favorite people",
                message: "Tap the heart on a person"
            )

        case .content:
            ScrollView {
                LazyVGrid(columns: cols, spacing: 12) {
                    if let inlineError = viewModel.inlineErrorMessage {
                        Text(inlineError)
                            .font(.footnote)
                            .foregroundStyle(Color.appTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .gridCellColumns(cols.count)
                    }

                    ForEach(viewModel.favorites) { person in
                        PersonCardView(person: person)
                            .onTapGesture {
                                navigator.goToPerson(id: person.id)
                            }
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
