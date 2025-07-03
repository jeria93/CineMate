//
//  WatchProviderListView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-02.
//

import SwiftUI

extension WatchProviderListView {
    
    static var previewWithData: some View {
        WatchProviderListView(
            providers: PreviewData.mockWatchProviders,
            selection: .flatrate
        )
        .padding()
    }
    
    static var previewEmpty: some View {
        WatchProviderListView(
            providers: [],
            selection: .buy
        )
        .padding()
    }
}
