//
//  SearchBarView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var onSubmit: () -> Void

    var body: some View {
        TextField("Search movies...", text: $text)
            .textFieldStyle(.roundedBorder)
            .padding()
            .onSubmit {
                onSubmit()
            }
    }
}

#Preview("SearchBarView") {
    SearchBarView(text: .constant("Batman")) {
    }
}
