//
//  Genre+Preview.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-30.
//

import Foundation

extension Genre {
    static let action = Genre(id: 28, name: "Action")
    static let adventure = Genre(id: 12, name: "Adventure")
    static let sciFi = Genre(id: 878, name: "Science Fiction")
    
    static let all: [Genre] = [action, adventure, sciFi]
}
