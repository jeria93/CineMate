//
//  DirectorView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-29.
//

import SwiftUI

struct DirectorView: View {
    let director: CrewMember?
    let repository: MovieProtocol
    @EnvironmentObject private var nav: AppNavigator

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Director")
                .font(.headline)

            if let director {
                HStack(spacing: 12) {
                    DirectorImageView(url: director.profileURL)
                    Text(director.name)
                        .font(.subheadline.bold())
                }
                .contentShape(Rectangle())
                .onTapGesture { nav.goToCrew(director) }
            } else {
                DirectorUnavailableView()
            }
        }
    }
}

#Preview("Director – Nolan") {
    DirectorView.previewWithDirector.withPreviewNavigation()
}

#Preview("Director – No Director") {
    DirectorView.previewNoDirector.withPreviewNavigation()
}

#Preview("Director – Partial") {
    DirectorView.previewPartialDirector.withPreviewNavigation()
}

/*
Tänk såhär, testa köra navigationlink först så kanske du direkt förstår hur du ska göra med enums
 */
