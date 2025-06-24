//
//  CastMoreButtonView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-18.
//

import SwiftUI

struct CastMoreButtonView: View {
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack {
                Image(systemName: "ellipsis")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.gray)

                Text("More")
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
            .frame(width: 80, height: 80)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CastMoreButtonView(onTap: {print("tapped")})
}
