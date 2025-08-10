//
//  FirestoreFavoritesRepository.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-09.
//

import Foundation
import FirebaseFirestore

final class FirestoreFavoritesRepository {

    private let firestore: Firestore

    init(firestore: Firestore = .firestore()) {
        self.firestore = firestore
    }

    func addFavorite() {
        
    }
}
