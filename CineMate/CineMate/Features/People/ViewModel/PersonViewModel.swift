//
//  PersonViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import Foundation

/// Loads and stores person screen data.
/// Includes detail data, external IDs, and movie credits.
@MainActor
final class PersonViewModel: ObservableObject {

  @Published var personDetail: PersonDetail?
  @Published var personExternalIDs: PersonExternalIDs?
  @Published var personMovies: [PersonMovieCredit] = []
  @Published var isLoading = false
  @Published var errorMessage: String?
  @Published private(set) var activePersonID: Int?

  private let repository: MovieProtocol

  private struct PersonBundle {
    let detail: PersonDetail
    let externalIDs: PersonExternalIDs?
  }

  /// Cache for person detail and external IDs.
  private var personCache: [Int: PersonBundle] = [:]
  /// Cache for person movie credits.
  private var creditsCache: [Int: [PersonMovieCredit]] = [:]

  /// Reused running requests per person.
  private var detailTasks: [Int: Task<PersonBundle, Error>] = [:]
  private var creditsTasks: [Int: Task<[PersonMovieCredit], Error>] = [:]

  init(repository: MovieProtocol) {
    self.repository = repository
  }

  /// Loads person data for one ID.
  /// Uses cache first, then network if needed.
  func loadPersonProfile(for personId: Int, forceRefresh: Bool = false) async {
    prepareForRequest(personId: personId, forceRefresh: forceRefresh)
    applyCacheIfAvailable(for: personId)

    if hasCompleteCache(for: personId) {
      isLoading = false
      errorMessage = nil
      return
    }

    isLoading = true
    errorMessage = nil

    async let detailResult = detailResult(for: personId, forceRefresh: forceRefresh)
    async let creditsResult = creditsResult(for: personId, forceRefresh: forceRefresh)

    let resolvedDetail = await detailResult
    let resolvedCredits = await creditsResult

    guard activePersonID == personId else { return }
    isLoading = false

    switch resolvedDetail {
    case .success(let bundle):
      personDetail = bundle.detail
      personExternalIDs = bundle.externalIDs
    case .failure(let error):
      handleDetailFailure(error, for: personId)
      return
    }

    switch resolvedCredits {
    case .success(let credits):
      personMovies = credits
      errorMessage = nil
    case .failure(let error):
      handleCreditsFailure(error, for: personId)
    }
  }

  /// Cancels running tasks for one person.
  func cancelOngoingTasks(for personId: Int) {
    detailTasks[personId]?.cancel()
    creditsTasks[personId]?.cancel()
    detailTasks[personId] = nil
    creditsTasks[personId] = nil

    guard activePersonID == personId else { return }
    isLoading = false
  }
}

extension PersonViewModel {
  /// Top 5 popular unique movies for the Known For section.
  var knownForMovies: [PersonMovieCredit] {
    var seenMovieIDs = Set<Int>()
    return
      personMovies
      .sorted { ($0.popularity ?? 0) > ($1.popularity ?? 0) }
      .filter { seenMovieIDs.insert($0.id).inserted }
      .prefix(5)
      .map { $0 }
  }

  func person(by id: Int) -> PersonDetail? {
    personCache[id]?.detail
  }

  func resetForNewPerson() {
    personDetail = nil
    personExternalIDs = nil
    personMovies = []
    errorMessage = nil
    isLoading = false
    activePersonID = nil
  }

  func hasCredits(for id: Int) -> Bool {
    creditsCache[id] != nil
  }
}

extension PersonViewModel {
  private func prepareForRequest(personId: Int, forceRefresh: Bool) {
    if activePersonID != personId {
      clearVisibleState()
      cancelTasksForOtherPeople(except: personId)
    }
    activePersonID = personId

    if forceRefresh {
      clearCache(for: personId)
      cancelOngoingTasks(for: personId)
    }
  }

  private func clearVisibleState() {
    personDetail = nil
    personExternalIDs = nil
    personMovies = []
    errorMessage = nil
    isLoading = false
  }

  private func clearCache(for personId: Int) {
    personCache[personId] = nil
    creditsCache[personId] = nil
  }

  private func cancelTasksForOtherPeople(except personId: Int) {
    let detailIDs = detailTasks.keys.filter { $0 != personId }
    for id in detailIDs {
      detailTasks[id]?.cancel()
      detailTasks[id] = nil
    }

    let creditIDs = creditsTasks.keys.filter { $0 != personId }
    for id in creditIDs {
      creditsTasks[id]?.cancel()
      creditsTasks[id] = nil
    }
  }

  private func hasCompleteCache(for personId: Int) -> Bool {
    personCache[personId] != nil && creditsCache[personId] != nil
  }

  private func applyCacheIfAvailable(for personId: Int) {
    if let bundle = personCache[personId] {
      personDetail = bundle.detail
      personExternalIDs = bundle.externalIDs
    }

    if let cachedCredits = creditsCache[personId] {
      personMovies = cachedCredits
    }
  }

  private func detailResult(for personId: Int, forceRefresh: Bool) async -> Result<
    PersonBundle, Error
  > {
    do {
      return .success(
        try await fetchDetailBundle(for: personId, forceRefresh: forceRefresh)
      )
    } catch {
      return .failure(error)
    }
  }

  private func creditsResult(for personId: Int, forceRefresh: Bool) async -> Result<
    [PersonMovieCredit], Error
  > {
    do {
      return .success(
        try await fetchCredits(for: personId, forceRefresh: forceRefresh)
      )
    } catch {
      return .failure(error)
    }
  }

  private func fetchDetailBundle(
    for personId: Int,
    forceRefresh: Bool
  ) async throws -> PersonBundle {
    if !forceRefresh, let cached = personCache[personId] {
      return cached
    }

    let task = detailTask(for: personId)
    defer { detailTasks[personId] = nil }

    let bundle = try await task.value
    personCache[personId] = bundle
    return bundle
  }

  private func fetchCredits(
    for personId: Int,
    forceRefresh: Bool
  ) async throws -> [PersonMovieCredit] {
    if !forceRefresh, let cached = creditsCache[personId] {
      return cached
    }

    let task = creditsTask(for: personId)
    defer { creditsTasks[personId] = nil }

    let credits = try await task.value
    creditsCache[personId] = credits
    return credits
  }

  private func detailTask(for personId: Int) -> Task<PersonBundle, Error> {
    if let runningTask = detailTasks[personId] {
      return runningTask
    }

    let task = Task { [repository] in
      async let detailRequest = repository.fetchPersonDetail(for: personId)
      async let externalRequest = repository.fetchPersonExternalIDs(for: personId)

      let detail = try await detailRequest
      let externalIDs: PersonExternalIDs?

      do {
        externalIDs = try await externalRequest
      } catch is CancellationError {
        throw CancellationError()
      } catch {
        externalIDs = nil
      }

      return PersonBundle(detail: detail, externalIDs: externalIDs)
    }

    detailTasks[personId] = task
    return task
  }

  private func creditsTask(for personId: Int) -> Task<[PersonMovieCredit], Error> {
    if let runningTask = creditsTasks[personId] {
      return runningTask
    }

    let task = Task { [repository] in
      try await repository.fetchPersonMovieCredits(for: personId)
    }

    creditsTasks[personId] = task
    return task
  }

  private func handleDetailFailure(_ error: Error, for personId: Int) {
    guard activePersonID == personId else { return }
    guard !(error is CancellationError) else { return }

    personDetail = nil
    personExternalIDs = nil
    personMovies = creditsCache[personId] ?? []
    errorMessage = error.localizedDescription
  }

  private func handleCreditsFailure(_ error: Error, for personId: Int) {
    guard activePersonID == personId else { return }
    guard !(error is CancellationError) else { return }

    personMovies = creditsCache[personId] ?? []
    errorMessage = error.localizedDescription
  }
}
