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

#Preview("Movie Category Picker") {
    MovieCategoryPicker.previewDefault
}

extension MovieCategoryPicker {
    /// Shows the picker with a default selected category
    static var previewDefault: some View {
        StatefulPreviewWrapper(MovieCategory.popular) { binding in
            MovieCategoryPicker(selectedCategory: binding)
                .padding()
                .background(Color(.systemBackground))
        }
    }
}

/// A helper wrapper for injecting @Binding into previews
struct StatefulPreviewWrapper<Value>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> AnyView

    init(_ value: Value, @ViewBuilder content: @escaping (Binding<Value>) -> some View) {
        _value = State(initialValue: value)
        self.content = { binding in AnyView(content(binding)) }
    }

    var body: some View {
        content($value)
    }
}
