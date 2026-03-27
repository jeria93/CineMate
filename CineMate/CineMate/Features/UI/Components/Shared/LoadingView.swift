//
//  LoadingView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

struct LoadingView: View {
    let title: String
    
    var body: some View {
        OverlayContainer(backdrop: .material) {
            OverlayCard {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.appPrimaryAction)
                    .scaleEffect(1.5)
                    .accessibilityHidden(true)
                
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(title)
        }
    }
}

#Preview("Default") {
    LoadingView(title: "Loading...")
}

#Preview("Searching") {
    LoadingView(title: "Searching movies...")
}
