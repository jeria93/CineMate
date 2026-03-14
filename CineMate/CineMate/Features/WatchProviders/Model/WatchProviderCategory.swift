//
//  WatchProviderCategory.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-02.
//

import Foundation

enum WatchProviderCategory: String, CaseIterable, Identifiable {
    case flatrate = "Stream"
    case rent = "Rent"
    case buy = "Buy"

    var id: String { rawValue }

    var title: String { rawValue }

    var iconName: String {
        switch self {
        case .flatrate:
            return "play.tv"
        case .rent:
            return "creditcard"
        case .buy:
            return "cart"
        }
    }

    var emptyTitle: String {
        switch self {
        case .flatrate:
            return "No streaming providers"
        case .rent:
            return "No rental providers"
        case .buy:
            return "No purchase providers"
        }
    }

    func providers(in region: WatchProviderRegion) -> [WatchProvider] {
        switch self {
        case .flatrate:
            return region.flatrate ?? []
        case .rent:
            return region.rent ?? []
        case .buy:
            return region.buy ?? []
        }
    }

    static func preferredInitialSelection(in region: WatchProviderRegion?) -> WatchProviderCategory {
        guard let region else { return .flatrate }
        return allCases.first(where: { !$0.providers(in: region).isEmpty }) ?? .flatrate
    }
}
