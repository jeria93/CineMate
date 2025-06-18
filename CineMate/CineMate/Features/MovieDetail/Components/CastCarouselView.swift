//
//  CastCarouselView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-17.
//

import SwiftUI

struct CastCarouselView: View {
    let cast: [CastMember]
    @State private var showAll = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Cast")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(showAll ? cast : Array(cast.prefix(15))) { member in
                        CastMemberView(member: member)
                    }
                    if !showAll && cast.count > 15 {
                        CastMoreButtonView {
                            withAnimation {
                                showAll = true
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
