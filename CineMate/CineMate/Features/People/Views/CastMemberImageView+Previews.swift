//
//  CastMemberImageView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

extension CastMemberImageView {
    
    /// Preview showing real cast image (e.g. Mark Hamill)
    static var previewWithImage: some View {
        CastMemberImageView(
            url: PreviewData.starWarsCredits().cast.first?.profileURL        )
        .padding()
        .background(Color(.systemBackground))
    }

    /// Preview showing fallback when image URL is nil or broken
    static var previewFallback: some View {
        CastMemberImageView(
            url: nil
        )
        .padding()
        .background(Color(.systemBackground))
    }
}
