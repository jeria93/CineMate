//
//  DiscoverSortMenu.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import SwiftUI

struct DiscoverSortMenu: View {
    @Binding var selectedSort: SortOption

    var body: some View {
        Menu("Sort") {
            ForEach(SortOption.allCases) { option in
                Button {
                    selectedSort = option
                } label: {
                    Label(option.label, systemImage: selectedSort == option ? "checkmark" : "")
                }
            }
        }
    }
}

#Preview("Default Selected") {
    DiscoverSortMenu.previewDefault
}

#Preview("No Selection") {
    DiscoverSortMenu.previewEmpty
}
