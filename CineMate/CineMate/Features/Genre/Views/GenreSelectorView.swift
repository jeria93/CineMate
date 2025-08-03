//
//  GenreSelectorView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//

import SwiftUI

/// A horizontal list of selectable genres with scroll-to-selected support.
/// - Includes an "All" chip to reset filters.
/// - Scrolls to the selected chip when changed.
/// - Handles rapid clicks without layout freezes.
struct GenreSelectorView: View {
    let genres: [Genre]
    let selectedGenreId: Int?
    let onSelect: (Int?) -> Void

    @State private var lastSelectedId: Int? = nil

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    // "All" chip with ID -1
                    GenreChipView(
                        genre: Genre(id: -1, name: "All"),
                        isSelected: selectedGenreId == nil
                    ) {
                        handleSelection(nil, proxy: proxy)
                    }
                    .id(-1)

                    // Dynamic genre chips
                    ForEach(genres) { genre in
                        GenreChipView(
                            genre: genre,
                            isSelected: genre.id == selectedGenreId
                        ) {
                            handleSelection(genre.id, proxy: proxy)
                        }
                        .id(genre.id)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 6)
            // Scroll only when the selection actually changes
            .onChange(of: selectedGenreId) { _, newValue in
                guard lastSelectedId != newValue else { return }
                lastSelectedId = newValue
                scrollToSelected(proxy: proxy, id: newValue ?? -1)
            }
        }
    }

    /// Handles user tapping a chip
    private func handleSelection(_ id: Int?, proxy: ScrollViewProxy) {
        onSelect(id)
    }

    /// Smoothly scrolls to the selected chip
    private func scrollToSelected(proxy: ScrollViewProxy, id: Int) {
        withAnimation(.easeInOut) {
            proxy.scrollTo(id, anchor: .center)
        }
    }
}

#Preview("Default") {
    GenreSelectorView.previewDefault
}
