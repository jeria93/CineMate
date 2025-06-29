//
//  SectionHeader.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-27.
//

import SwiftUI

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title2.bold())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }
}

#Preview("Section Header") {
    SectionHeader(title: "Biography")
}
