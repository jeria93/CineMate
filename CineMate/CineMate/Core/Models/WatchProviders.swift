//
//  WatchProviders.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-01.
//

import Foundation


/// Represents the full response from TMDB's `/movie/{movie_id}/watch/providers` endpoint.
/// This response contains all available watch providers grouped by country code (e.g., "SE", "US").
///
/// - Endpoint: [Get Watch Providers for a Movie](https://developer.themoviedb.org/reference/movie-watch-providers)
/// - Example usage: To fetch where a specific movie can be streamed, rented or bought.
struct WatchProvidersResponse: Decodable {
    let results: [String: WatchProviderRegion]
}

/// Represents the streaming availability for a movie in a specific country/region.
///
/// - Contains links and available options for flat-rate streaming, renting or buying.
/// - Usually accessed by looking up a country (like "SE") in the `results` dictionary from `WatchProvidersResponse`
struct WatchProviderRegion: Decodable {

    let link: String?
    /// Providers where the movie is available to stream with a subscription (e.g. Netflix)
    let flatrate: [WatchProvider]?
    let rent: [WatchProvider]?
    let buy: [WatchProvider]?
}

/// Represents a single watch provider (e.g., Netflix, Prime Video).
///
/// - Can be used in flat-rate, rent, or buy lists.
/// - Also used globally via `/watch/providers/movie` to get all available providers.
///
/// - Endpoint:
///   - [Get Watch Providers for a Movie](https://developer.themoviedb.org/reference/movie-watch-providers)
///   - [Get All Watch Providers](https://developer.themoviedb.org/reference/watch-providers-movie-list)
struct WatchProvider: Decodable, Identifiable, Equatable {

    let providerId: Int
    let providerName: String
    let logoPath: String?

    var id: Int { providerId }
    var logoURL: URL? {
        TMDBImageHelper.url(for: logoPath, size: .w92)
    }
}
