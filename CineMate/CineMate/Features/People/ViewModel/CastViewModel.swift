//
//  CastViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-18.
//

import Foundation

/// Loads and caches movie cast and crew data.
@MainActor
final class CastViewModel: ObservableObject {
  @Published var cast: [CastMember] = []
  @Published var crew: [CrewMember] = []
  @Published var isLoading = false
  @Published var errorMessage: String?
  @Published private(set) var activeMovieID: Int?

  internal let repository: MovieProtocol

  private var creditsCache: [Int: MovieCredits] = [:]
  private var runningTasks: [Int: Task<MovieCredits, Error>] = [:]
  private var requestedMovieID: Int?

  init(repository: MovieProtocol) {
    self.repository = repository
  }

  /// Loads credits for one movie.
  /// Reuses cache and any running request for the same movie ID.
  func loadCredits(for movieId: Int, forceRefresh: Bool = false) async {
    requestedMovieID = movieId

    if activeMovieID != movieId {
      clearVisibleState(for: movieId)
    }

    if forceRefresh {
      creditsCache[movieId] = nil
      cancelCreditsLoad(for: movieId)
    } else if let cached = creditsCache[movieId] {
      apply(credits: cached, for: movieId)
      return
    }

    isLoading = true
    errorMessage = nil

    do {
      let credits = try await fetchCredits(for: movieId)
      guard requestedMovieID == movieId else { return }
      apply(credits: credits, for: movieId)
    } catch is CancellationError {
      guard requestedMovieID == movieId else { return }
      isLoading = false
    } catch {
      guard requestedMovieID == movieId else { return }
      activeMovieID = movieId
      cast = []
      crew = []
      errorMessage = error.localizedDescription
      isLoading = false
    }
  }

  var credits: MovieCredits? {
    guard let activeMovieID else { return nil }
    return MovieCredits(id: activeMovieID, cast: cast, crew: crew)
  }

  private func apply(credits: MovieCredits, for movieId: Int) {
    activeMovieID = movieId
    cast = credits.cast
    crew = credits.crew
    errorMessage = nil
    isLoading = false
  }

  private func clearVisibleState(for movieId: Int) {
    activeMovieID = movieId
    cast = []
    crew = []
    errorMessage = nil
    isLoading = false
  }

  private func fetchCredits(for movieId: Int) async throws -> MovieCredits {
    if let cached = creditsCache[movieId] {
      return cached
    }

    let task = creditsTask(for: movieId)
    defer { runningTasks[movieId] = nil }

    let credits = try await task.value
    creditsCache[movieId] = credits
    return credits
  }

  private func creditsTask(for movieId: Int) -> Task<MovieCredits, Error> {
    if let runningTask = runningTasks[movieId] {
      return runningTask
    }

    let task = Task { [repository] in
      try await repository.fetchMovieCredits(for: movieId)
    }

    runningTasks[movieId] = task
    return task
  }

  func cancelCreditsLoad(for movieId: Int) {
    runningTasks[movieId]?.cancel()
    runningTasks[movieId] = nil

    guard requestedMovieID == movieId else { return }
    isLoading = false
  }

  func seedPreviewCredits(_ credits: MovieCredits) {
    creditsCache[credits.id] = credits
    apply(credits: credits, for: credits.id)
  }
}
