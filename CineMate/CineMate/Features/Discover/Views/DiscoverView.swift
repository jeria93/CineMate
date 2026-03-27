//
//  DiscoverView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import SwiftUI

/// Main Discover screen.
/// - Shows loading, error, empty state or movie sections depending on state.
/// - Supports pull-to-refresh and async data fetching.
struct DiscoverView: View {
    @ObservedObject var viewModel: DiscoverViewModel

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Discover")
            .task {
                await viewModel.refreshCurrentSelection()
            }
            .refreshable {
                await viewModel.refreshCurrentSelection(forceReload: true)
            }
    }

    /// Conditionally renders the correct view based on the current state.
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.allSectionsAreEmpty {
            LoadingView(title: "Loading…")
        } else if let err = viewModel.error, viewModel.allSectionsAreEmpty {
            ErrorMessageView(
                title: "Something went wrong",
                message: err.localizedDescription,
                onRetry: { Task { await viewModel.refreshCurrentSelection(forceReload: true) } }
            )
        } else if viewModel.allSectionsAreEmpty {
            EmptyStateView(
                systemImage: "film",
                title: "No movies to show.",
                message: "There’s no content here at the moment."
            )
        } else {
            DiscoverContentView(viewModel: viewModel)
                .overlay(alignment: .top) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.appPrimaryAction)
                            .padding(10)
                            .background(Color.appSurface.opacity(0.95), in: Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.appPrimaryAction.opacity(0.25), lineWidth: 1)
                            )
                            .padding(.top, 8)
                    }
                }
                .overlay(alignment: .bottom) {
                    if let err = viewModel.error, !viewModel.isLoading {
                        Text(err.localizedDescription)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.appTextSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.appSurface.opacity(0.95), in: Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.appTextSecondary.opacity(0.20), lineWidth: 1)
                            )
                            .padding(.bottom, 12)
                    }
                }
        }
    }
}

#Preview("Default") {
    DiscoverView.previewDefault
}

#Preview("Loading") {
    DiscoverView.previewLoading
}

#Preview("Empty") {
    DiscoverView.previewEmpty
}

#Preview("Error") {
    DiscoverView.previewError
}

#Preview("One Section") {
    DiscoverView.previewOneSection
}
