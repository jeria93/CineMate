//
//  MovieDetail.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-13.
//

import Foundation

struct MovieDetail: Codable {
    let id: Int
    let runtime: Int?
    let budget: Int?
    let revenue: Int?
    let homepage: String?
    let status: String?
    let productionCompanies: [ProductionCompany]
    let productionCountries: [ProductionCountry]
}

struct ProductionCompany: Codable {
    let name: String
}

struct ProductionCountry: Codable {
    let name: String
}
