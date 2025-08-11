//
//  FirestoreFavoritePeopleRepository.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-11.
//

import Foundation
import FirebaseFirestore

final class FirestoreFavoritePeopleRepository {
    private let firestore: Firestore

    init(firestore: Firestore = .firestore()) {
        self.firestore = firestore
    }

}
