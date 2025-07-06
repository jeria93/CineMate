//
//  EmptyResultsView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

struct EmptyResultsView: View {
    var body: some View {
        Text("No results found")
            .foregroundStyle(.secondary)
            .padding()
    }
}

#Preview("EmptyResultsView") {
    EmptyResultsView()
}
