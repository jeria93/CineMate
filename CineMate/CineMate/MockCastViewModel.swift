//
//  MockCastViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-18.
//

import Foundation

@MainActor
final class MockCastViewModel: CastViewModelProtocol {
    func loadCredits(for movieId: Int) async {
        print("mock data")
    }
    
    @Published var cast: [CastMember]
    @Published var crew: [CrewMember]
    @Published var isLoading: Bool
    @Published var errorMessage: String?

    init(state: MockState = .standard) {
        switch state {
        case .standard:
            self.cast = PreviewData.starWarsCredits.cast
            self.crew = PreviewData.starWarsCredits.crew
            self.isLoading = false
            self.errorMessage = nil
        case .empty:
            self.cast = []
            self.crew = []
            self.isLoading = false
            self.errorMessage = nil
        case .loading:
            self.cast = []
            self.crew = []
            self.isLoading = true
            self.errorMessage = nil
        case .error:
            self.cast = []
            self.crew = []
            self.isLoading = false
            self.errorMessage = "Failed to load cast."
        }
    }

    enum MockState {
        case standard
        case empty
        case loading
        case error
    }
}
