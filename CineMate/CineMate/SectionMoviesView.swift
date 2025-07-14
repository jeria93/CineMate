//
//  SectionMoviesView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import SwiftUI

struct SectionMoviesView: View {
    @StateObject private var viewModel: SectionMoviesViewModel
    let title: String
    
    init(title: String, viewModel: SectionMoviesViewModel) {
        self.title = title
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 16)], spacing: 16) {
                ForEach(viewModel.movies) { movie in
                    NavigationLink {
                        //                        MovieDetailView(movie: movie)
                    } label: {
                        MoviePosterView(movie: movie)
                            .onAppear {
                                Task {
                                    await viewModel.loadMoreIfNeeded(currentMovie: movie)
                                }
                            }
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle(title)
        .task {
            await viewModel.loadNextPage()
        }
    }
}

#Preview("Default") {
    SectionMoviesView.previewDefault
}

#Preview("Empty") {
    SectionMoviesView.previewEmpty
}

#Preview("One Movie") {
    SectionMoviesView.previewOneMovie
}
