//
//  MovieCategoryPicker.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import SwiftUI

struct MovieCategoryPicker: View {
    @Binding var selectedCategory: MovieCategory

    var body: some View {
        Picker("Category", selection: $selectedCategory) {
            ForEach(MovieCategory.allCases, id: \.self) { category in
                Text(category.displayName).tag(category)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
}
