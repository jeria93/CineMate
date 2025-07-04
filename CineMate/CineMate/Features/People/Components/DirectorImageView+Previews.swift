//
//  DirectorImageView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

extension DirectorImageView {
    /// Shows a valid image preview
    static var previewWithImage: some View {
        DirectorImageView(url: URL(string: "https://example.com/image.jpg"))
            .padding()
            .background(Color(.systemBackground))
    }

    /// Shows fallback UI when no image is available
    static var previewFallback: some View {
        DirectorImageView(url: nil)
            .padding()
            .background(Color(.systemBackground))
    }
}
