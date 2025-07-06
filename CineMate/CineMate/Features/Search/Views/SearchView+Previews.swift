//
//  SearchView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import SwiftUI

extension SearchView {
    static var previewDefault: some View {
        SearchView(viewModel: {
            let vm = SearchViewModel()
            vm.query = "Star"
            vm.results = PreviewData.moviesList
            return vm
        }())
    }
}
