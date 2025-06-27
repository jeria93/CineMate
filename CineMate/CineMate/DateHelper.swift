//
//  DateHelper.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-27.
//

import Foundation

/// A utility for working with date strings and calculating ages, durations, etc.
enum DateHelper {

    /// Parses a string with format "yyyy-MM-dd" into a Date.
    static func parse(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: dateString)
    }

    /// Calculates age in years from a birthdate string ("yyyy-MM-dd") to today.
    static func calculateAge(from birthday: String) -> Int? {
        guard let birthDate = parse(birthday) else { return nil }
        let now = Date()
        let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: now)
        return ageComponents.year
    }

    /// Calculates lived years between birth and death (both "yyyy-MM-dd").
    static func calculateYearsLived(birthday: String, deathday: String) -> Int? {
        guard let birthDate = parse(birthday),
              let deathDate = parse(deathday) else { return nil }

        let components = Calendar.current.dateComponents([.year], from: birthDate, to: deathDate)
        return components.year
    }
}
