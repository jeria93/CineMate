//
//  CastCarouselView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-17.
//

import SwiftUI

struct CastCarouselView: View {
    let cast: [CastMember]
    @State private var showAll = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cast")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(showAll ? cast : Array(cast.prefix(15))) { member in
                        VStack(alignment: .center, spacing: 4) {
                            AsyncImage(url: member.profileURL) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())

                            Text(member.name)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .truncationMode(.tail)
                                .frame(height: 34)

                            Text(member.character?.isEmpty == false ? member.character! : "Unknown")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .truncationMode(.tail)
                                .frame(height: 28)
                        }
                        .frame(width: 80)
                        .onTapGesture {
                            // TODO: Navigate to ActorDetailView with member.id
                            print("Tapped on \(member.name)")
                        }
                    }

                    if !showAll && cast.count > 15 {
                        Button {
                            withAnimation {
                                showAll = true
                            }
                        } label: {
                            VStack {
                                Image(systemName: "ellipsis")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.gray)

                                Text("More")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 80, height: 112)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    CastCarouselView(cast: PreviewData.starWarsCredits.cast)
}

#Preview("Long Names and Roles") {
    let longCast: [CastMember] = [
        CastMember(
            id: 1,
            name: "Maximilian Alexander von Habsburg",
            character: "Lord Commander of the Galactic Imperial Special Forces",
            profilePath: nil
        ),
        CastMember(
            id: 2,
            name: "A Very Very Long Actor Name That Wraps",
            character: "The Mysterious Wanderer of the Outer Realms",
            profilePath: nil
        ),
        CastMember(
            id: 3,
            name: "Short Name",
            character: "Short Role",
            profilePath: nil
        ),
        CastMember(
            id: 4,
            name: "No Role Person",
            character: nil,
            profilePath: nil
        )
    ]

    return CastCarouselView(cast: longCast)
        .padding()
        .background(Color(.systemBackground))
}
