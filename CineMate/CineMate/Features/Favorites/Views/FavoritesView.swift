//
//  FavoritesView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-12.
//

import SwiftUI

struct FavoritesView: View {
    enum Segment { case movies, people }

    @State private var segment: Segment = .movies
    @ObservedObject var moviesVM: FavoriteMoviesViewModel
    @ObservedObject var peopleVM: FavoritePeopleViewModel

    var body: some View {
        VStack {
            Picker("", selection: $segment) {
                Text("Movies").tag(Segment.movies)
                Text("People").tag(Segment.people)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            switch segment {
            case .movies:
                FavoriteMoviesView(viewModel: moviesVM)
            case .people:
                FavoritePeopleGrid(viewModel: peopleVM)
            }
        }
        .navigationTitle("Favorites")
    }
}

#Preview("Default")     { FavoritesView.previewDefault }
#Preview("Movies only") { FavoritesView.previewMoviesOnly }
#Preview("People many") { FavoritesView.previewPeopleMany }
