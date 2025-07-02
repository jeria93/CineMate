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

    var id: String { self.rawValue }

    var iconName: String {
        switch self {
        case .flatrate: return "play.tv"
        case .rent:     return "creditcard"
        case .buy:      return "cart"
        }
    }
}
