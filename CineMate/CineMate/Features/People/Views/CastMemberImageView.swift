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
    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
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
              .fill(Color.gray.opacity(0.12))
            ProgressView()
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
      .foregroundStyle(.gray)
      .padding(12)
      .background(Color.gray.opacity(0.1))
  }
}

#Preview("With Image – Mark Hamill") {
  CastMemberImageView.previewWithImage
}

#Preview("Fallback – Missing Image") {
  CastMemberImageView.previewFallback
}
