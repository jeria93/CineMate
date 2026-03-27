//
//  WatchProvidersView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-01.
//

import SwiftUI

struct WatchProvidersView: View {
    let movieId: Int
    let availability: WatchProviderAvailability?
    let isLoading: Bool
    let errorMessage: String?

    @State private var selection: WatchProviderCategory = .flatrate

    private var resolvedRegion: WatchProviderRegion? {
        availability?.region
    }

    private var selectedProviders: [WatchProvider] {
        guard let resolvedRegion else { return [] }
        return selection.providers(in: resolvedRegion)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Where to watch")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            regionHeader
            contentView

            if let url = resolvedRegion?.linkURL {
                Link(destination: url) {
                    HStack {
                        Text("See all streaming options")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.appPrimaryAction)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.appSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.appTextSecondary.opacity(0.18), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            syncSelectionWithResolvedRegion()
        }
        .onChange(of: movieId) { _, _ in
            syncSelectionWithResolvedRegion()
        }
        .onChange(of: availability?.resolvedRegionCode) { _, _ in
            syncSelectionWithResolvedRegion()
        }
    }

    @ViewBuilder
    private var regionHeader: some View {
        if let availability {
            VStack(alignment: .leading, spacing: 2) {
                if let resolvedRegionCode = availability.resolvedRegionCode {
                    let resolvedName = availability.resolvedRegionName ?? resolvedRegionCode
                    Text("\(availability.sourceLabel): \(resolvedName) (\(resolvedRegionCode))")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                } else {
                    Text(
                        "No watch-provider region data for \(availability.requestedRegionName) (\(availability.requestedRegionCode))."
                    )
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                }

                if availability.source != .requestedRegion {
                    let requested =
                        "\(availability.requestedRegionName) (\(availability.requestedRegionCode))"
                    let fallback =
                        "\(availability.fallbackRegionName) (\(availability.fallbackRegionCode))"
                    Text("Requested: \(requested) · Fallback: \(fallback)")
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        } else if isLoading {
            Text("Resolving watch providers for your region…")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if isLoading, availability == nil {
            ProgressView("Loading watch providers…")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
        } else if let errorMessage, availability == nil {
            fallbackCard(
                title: "Could not load watch providers",
                message: errorMessage,
                iconName: "exclamationmark.triangle"
            )
        } else if let resolvedRegion {
            WatchProviderCategoryPicker(selection: $selection, region: resolvedRegion)
            WatchProviderListView(
                providers: selectedProviders,
                selection: selection,
                resolvedRegionCode: availability?.resolvedRegionCode,
                resolvedRegionName: availability?.resolvedRegionName
            )
        } else {
            fallbackCard(
                title: "No regional provider data",
                message:
                    "TMDB has no watch-provider data for your region or fallback region right now.",
                iconName: "globe.badge.chevron.backward"
            )
        }
    }

    private func syncSelectionWithResolvedRegion() {
        selection = WatchProviderCategory.preferredInitialSelection(in: availability?.region)
    }

    private func fallbackCard(title: String, message: String, iconName: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: iconName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
            Text(message)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.appSurface)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.appTextSecondary.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview("With Mock Providers") {
    WatchProvidersView.preview
}

#Preview("No Providers") {
    WatchProvidersView.previewEmpty
}

#Preview("Fallback Region") {
    WatchProvidersView.previewFallbackRegion
}

#Preview("No Region Data") {
    WatchProvidersView.previewNoRegionData
}

#Preview("Loading") {
    WatchProvidersView.previewLoading
}

#Preview("Error") {
    WatchProvidersView.previewError
}
