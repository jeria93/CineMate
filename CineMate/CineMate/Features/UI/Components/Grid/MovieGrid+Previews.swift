//
//  MovieGrid+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

extension MovieGridView {
    static var previewDefault: some View {
        PreviewFactory.movieGridDefault
            .background(Color(.systemBackground))
    }

    static var previewLongList: some View {
        PreviewFactory.movieGridLong
            .background(Color(.systemBackground))
    }

    static var previewEmpty: some View {
        PreviewFactory.movieGridEmpty
            .background(Color(.systemBackground))
    }
}
