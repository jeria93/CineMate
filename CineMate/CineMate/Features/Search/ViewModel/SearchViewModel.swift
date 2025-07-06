//
//  SearchViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [Movie] = []

    func performSearch() {
        results = PreviewData.moviesList.filter {
            $0.title.lowercased().contains(query.lowercased())
        }
    }
}
