//
//  BiographyView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-25.
//

import SwiftUI

struct BiographyView: View {
    let text: String
    private let maxLength = 250

    @State private var isExpanded = false

    var shouldTruncate: Bool {
        text.count > maxLength
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                Text(isExpanded || !shouldTruncate ? text : String(text.prefix(maxLength)) + "...")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .animation(.easeInOut, value: isExpanded)

                // Fade effect only when truncated and not expanded
                if shouldTruncate && !isExpanded {
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .white]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 40)
                    .allowsHitTesting(false)
                }
            }

            if shouldTruncate {
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Text(isExpanded ? "Show less" : "Read more")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

#Preview {
    BiographyView(text: String(repeating: "This is a long biography text. ", count: 20))
}
