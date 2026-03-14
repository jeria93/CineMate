//
//  WatchProviderRegion+Extensions.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-01.
//

import Foundation

extension WatchProvidersResponse {
    /// Resolves a deterministic region using preferred region first,
    /// then fallback region, then best available data.
    func resolveAvailability(
        preferredRegionCode: String?,
        fallbackRegionCode: String = WatchProviderAvailability.defaultFallbackRegionCode
    ) -> WatchProviderAvailability {
        let normalizedFallback = Self.normalizedRegionCode(fallbackRegionCode)
        ?? WatchProviderAvailability.defaultFallbackRegionCode
        let normalizedRequested = Self.normalizedRegionCode(preferredRegionCode)
        ?? normalizedFallback

        let regionsByCode = normalizedResultsByRegionCode

        if let region = regionsByCode[normalizedRequested] {
            return WatchProviderAvailability(
                requestedRegionCode: normalizedRequested,
                fallbackRegionCode: normalizedFallback,
                resolvedRegionCode: normalizedRequested,
                source: .requestedRegion,
                region: region
            )
        }

        if normalizedRequested != normalizedFallback,
           let region = regionsByCode[normalizedFallback] {
            return WatchProviderAvailability(
                requestedRegionCode: normalizedRequested,
                fallbackRegionCode: normalizedFallback,
                resolvedRegionCode: normalizedFallback,
                source: .fallbackRegion,
                region: region
            )
        }

        let sortedRegionCodes = regionsByCode.keys.sorted()

        if let bestRegionCode = sortedRegionCodes.first(
            where: { code in
                regionsByCode[code]?.hasCatalogOptions == true
            }
        ), let region = regionsByCode[bestRegionCode] {
            return WatchProviderAvailability(
                requestedRegionCode: normalizedRequested,
                fallbackRegionCode: normalizedFallback,
                resolvedRegionCode: bestRegionCode,
                source: .firstRegionWithCatalogOptions,
                region: region
            )
        }

        if let availableRegionCode = sortedRegionCodes.first,
           let region = regionsByCode[availableRegionCode] {
            return WatchProviderAvailability(
                requestedRegionCode: normalizedRequested,
                fallbackRegionCode: normalizedFallback,
                resolvedRegionCode: availableRegionCode,
                source: .firstAvailableRegion,
                region: region
            )
        }

        return .unavailable(
            requestedRegionCode: normalizedRequested,
            fallbackRegionCode: normalizedFallback
        )
    }

    private var normalizedResultsByRegionCode: [String: WatchProviderRegion] {
        var map: [String: WatchProviderRegion] = [:]
        for (regionCode, region) in results {
            guard let normalizedCode = Self.normalizedRegionCode(regionCode) else { continue }
            if map[normalizedCode] == nil {
                map[normalizedCode] = region
            }
        }
        return map
    }

    private static func normalizedRegionCode(_ rawRegionCode: String?) -> String? {
        guard let rawRegionCode else { return nil }
        let normalizedCode = rawRegionCode
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()

        guard normalizedCode.count == 2 else { return nil }
        let isASCIIAlpha = normalizedCode.unicodeScalars.allSatisfy {
            (65...90).contains(Int($0.value))
        }
        return isASCIIAlpha ? normalizedCode : nil
    }
}
