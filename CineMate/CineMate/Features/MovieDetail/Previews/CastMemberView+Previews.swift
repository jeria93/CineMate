//
//  CastMemberView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-18.
//


import SwiftUI

extension CastMemberView {
    static var markHamillPreview: some View {
        CastMemberView(
            member: .markHamill
        )
    }
    
    static var unknownActorPreview: some View {
        CastMemberView(
            member: .unknownActor
        )
    }
    
    static var longNamePreview: some View {
        CastMemberView(
            member: .longName
        )
    }
    
    static var withInjectedViewModel: some View {
        CastMemberDetailView(
            member: .markHamill,
            viewModel: PersonViewModel(repository: MockMovieRepository())
        )
    }
}

extension CastMember {
    static let markHamill = CastMember(
        id: 1,
        name: "Mark Hamill",
        character: "Luke Skywalker",
        profilePath: "/zMKcrbRz0JzB7C2KQku8gsGCeFs.jpg"
    )
    
    static let unknownActor = CastMember(
        id: 2,
        name: "Unknown Actor",
        character: nil,
        profilePath: nil
    )
    
    static let longName = CastMember(
        id: 3,
        name: "This is a really really really long actor name",
        character: "Extraordinary Sidekick of Episode 47 Part 3",
        profilePath: nil
    )
}
