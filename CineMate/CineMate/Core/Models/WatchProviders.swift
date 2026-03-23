//
//  WatchProviders.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-01.
//

import Foundation

/// Represents TMDB `/movie/{movie_id}/watch/providers` response.
/// Keys in `results` are ISO 3166-1 region codes (e.g. `SE`, `US`).
struct WatchProvidersResponse: Decodable, Equatable {
    let results: [String: WatchProviderRegion]
}

/// Availability for one region from TMDB watch providers response.
/// A region may include stream (`flatrate`), rent, buy and optional ad/free entries.
struct WatchProviderRegion: Decodable, Equatable {
    let link: String?
    let flatrate: [WatchProvider]?
    let rent: [WatchProvider]?
    let buy: [WatchProvider]?
    let free: [WatchProvider]?
    let ads: [WatchProvider]?

    /// True if any of the app-visible categories has providers.
    var hasCatalogOptions: Bool {
        hasProviders(flatrate) || hasProviders(rent) || hasProviders(buy)
    }

    /// True if any TMDB category has providers.
    var hasAnyOptions: Bool {
        hasCatalogOptions || hasProviders(free) || hasProviders(ads)
    }

    /// Valid URL built from TMDB link field.
    var linkURL: URL? {
        guard let link, let url = URL(string: link) else { return nil }
        return url
    }

    private func hasProviders(_ providers: [WatchProvider]?) -> Bool {
        guard let providers else { return false }
        return !providers.isEmpty
    }
}

/// Availability state after resolving a preferred region and fallbacks.
struct WatchProviderAvailability: Equatable {
    static let defaultFallbackRegionCode = "US"

    let requestedRegionCode: String
    let fallbackRegionCode: String
    let resolvedRegionCode: String?
    let source: WatchProviderRegionResolutionSource
    let region: WatchProviderRegion?

    var hasResolvedRegion: Bool {
        resolvedRegionCode != nil && region != nil
    }

    var requestedRegionName: String {
        Self.localizedRegionName(for: requestedRegionCode)
    }

    var fallbackRegionName: String {
        Self.localizedRegionName(for: fallbackRegionCode)
    }

    var resolvedRegionName: String? {
        guard let resolvedRegionCode else { return nil }
        return Self.localizedRegionName(for: resolvedRegionCode)
    }

    var sourceLabel: String {
        switch source {
        case .requestedRegion:
            return "Current region"
        case .fallbackRegion:
            return "Fallback region"
        case .firstRegionWithCatalogOptions:
            return "Best available region"
        case .firstAvailableRegion:
            return "Available region"
        case .unavailable:
            return "No region data"
        }
    }

    static func unavailable(
        requestedRegionCode: String,
        fallbackRegionCode: String
    ) -> WatchProviderAvailability {
        WatchProviderAvailability(
            requestedRegionCode: requestedRegionCode,
            fallbackRegionCode: fallbackRegionCode,
            resolvedRegionCode: nil,
            source: .unavailable,
            region: nil
        )
    }

    private static func localizedRegionName(for regionCode: String) -> String {
        Locale.current.localizedString(forRegionCode: regionCode)
        ?? Locale(identifier: "en_US_POSIX").localizedString(forRegionCode: regionCode)
        ?? regionCode
    }
}

enum WatchProviderRegionResolutionSource: String, Equatable {
    case requestedRegion
    case fallbackRegion
    case firstRegionWithCatalogOptions
    case firstAvailableRegion
    case unavailable
}

/// Represents one provider (e.g. Netflix, Prime Video).
struct WatchProvider: Decodable, Identifiable, Equatable {
    let providerId: Int
    let providerName: String
    let logoPath: String?

    var id: Int { providerId }

    var displayName: String {
        let trimmed = providerName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Unknown provider" : trimmed
    }

    var logoURL: URL? {
        TMDBImageHelper.url(for: logoPath, size: .w92)
    }
}

extension WatchProviderRegion {
    static let empty = WatchProviderRegion(
        link: nil,
        flatrate: nil,
        rent: nil,
        buy: nil,
        free: nil,
        ads: nil
    )
}
