//
//  CastViewModelProtocol.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-18.
//

import Foundation

@MainActor
protocol CastViewModelProtocol: ObservableObject {
    var cast: [CastMember] { get }
    var crew: [CrewMember] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }

    func loadCredits(for movieId: Int) async
}
