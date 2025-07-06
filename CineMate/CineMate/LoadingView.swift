//
//  LoadingView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

struct LoadingView: View {
    var text: String = "Loading..."
    
    var body: some View {
        ProgressView(text)
            .padding()
    }
}

#Preview("LoadingView") {
    LoadingView(text: "Searching movies...")
}
