//
//  CastMemberImageView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-22.
//

import SwiftUI

struct CastMemberImageView: View {
  let url: URL?

  var body: some View {
    imageView
    .frame(width: 180, height: 180)
    .clipShape(Circle())
    .overlay(Circle().stroke(Color.appTextSecondary.opacity(0.25), lineWidth: 1))
  }

  @ViewBuilder
  private var imageView: some View {
    if ProcessInfo.processInfo.isPreview {
      fallbackImage
    } else {
      AsyncImage(url: url) { phase in
        switch phase {
        case .empty:
          ZStack {
            Circle()
              .fill(Color.appSurface)
            ProgressView()
              .tint(.appPrimaryAction)
          }

        case .success(let image):
          image
            .resizable()
            .scaledToFill()

        case .failure:
          fallbackImage

        @unknown default:
          fallbackImage
        }
      }
    }
  }

  private var fallbackImage: some View {
    Image(systemName: "person.circle.fill")
      .resizable()
      .scaledToFit()
      .foregroundStyle(Color.appTextSecondary)
      .padding(12)
      .background(Color.appSurface)
  }
}

#Preview("With Image – Mark Hamill") {
  CastMemberImageView.previewWithImage
}

#Preview("Fallback – Missing Image") {
  CastMemberImageView.previewFallback
}
