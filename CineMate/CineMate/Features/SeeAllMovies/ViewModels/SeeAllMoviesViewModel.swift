//
//  SeeAllMoviesViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//

import Foundation

@MainActor
final class SeeAllMoviesViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var hasError: Bool { errorMessage != nil }
    
    private let repository: MovieProtocol
    private let filter: DiscoverFilter
    
    let pagination = PaginationManager()
    
    private var movieCache: [DiscoverFilter: [Int: [Movie]]] = [:]
    private var loadedMovieIDs = Set<Int>()
    private var fetchTask: Task<Void, Never>?
    
    init(repository: MovieProtocol, filter: DiscoverFilter) {
        self.repository = repository
        self.filter = filter
    }
    
    func loadInitialMovies() async {
        guard !ProcessInfo.processInfo.isPreview else { return }
        guard movies.isEmpty else { return }
        await fetchNextPage()
    }
    
    func fetchNextPage() async {
        guard !ProcessInfo.processInfo.isPreview else { return }
        guard fetchTask == nil else {
            await fetchTask?.value
            return
        }
        
        errorMessage = nil
        
        let key = currentFilterKey
        let isFirstLoad = movies.isEmpty && pagination.state.currentPage == 1
        let pageToFetch = isFirstLoad ? 1 : pagination.state.currentPage + 1
        
        if let cached = movieCache[key]?[pageToFetch] {
            appendUniqueMovies(cached)
            let derivedTotalPages = pageToFetch + (cached.isEmpty ? 0 : 1)
            pagination.finishFetching(page: pageToFetch, totalPages: derivedTotalPages)
            return
        }
        
        if !isFirstLoad {
            guard pagination.startFetchingNextPage() else { return }
        }
        
        let task = Task { [weak self] in
            guard let self else { return }
            self.isLoading = true
            defer {
                self.isLoading = false
                self.fetchTask = nil
            }
            
            do {
                let filterForPage = self.filter.withPage(pageToFetch)
                let newMovies = try await self.repository.discoverMovies(filters: filterForPage.queryItems)
                self.movieCache[key, default: [:]][pageToFetch] = newMovies
                self.appendUniqueMovies(newMovies)
                
                // Discover endpoint can return variable page sizes across filters.
                // Keep pagination open until a request returns an empty page.
                let derivedTotalPages = pageToFetch + (newMovies.isEmpty ? 0 : 1)
                self.pagination.finishFetching(page: pageToFetch, totalPages: derivedTotalPages)
            } catch {
                if !Task.isCancelled {
                    self.errorMessage = error.localizedDescription
                }
                self.pagination.cancelFetching()
            }
        }
        
        fetchTask = task
        await task.value
    }
    
    func loadNextPageIfNeeded(currentItem: Movie) async {
        guard
            let last = movies.last,
            last.id == currentItem.id,
            pagination.hasMorePages
        else { return }
        await fetchNextPage()
    }
    
    func clearCache() {
        fetchTask?.cancel()
        fetchTask = nil
        movies.removeAll()
        loadedMovieIDs.removeAll()
        movieCache.removeAll()
        pagination.reset()
        errorMessage = nil
    }
    
    private var currentFilterKey: DiscoverFilter {
        var updated = filter
        updated.page = 0
        return updated
    }
    
    private func appendUniqueMovies(_ newMovies: [Movie]) {
        for movie in newMovies where !loadedMovieIDs.contains(movie.id) {
            movies.append(movie)
            loadedMovieIDs.insert(movie.id)
        }
    }
}
