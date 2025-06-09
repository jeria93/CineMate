//
//  MovieProtocol.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation

protocol MovieProtocol {
    func fetchPopularMovies() async throws -> [Movie]
    func fetchTrendingMovies() async throws -> [Movie]
    func fetchTopRatedMovies() async throws -> [Movie]
    func fetchUpcomingMovies() async throws -> [Movie]
}
