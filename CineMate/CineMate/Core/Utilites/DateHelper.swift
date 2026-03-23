//
//  DateHelper.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-27.
//

import Foundation

/// A utility for working with date strings and calculating ages, durations, etc.
enum DateHelper {
    private static let utcCalendar = Calendar(identifier: .gregorian)
    private static let tmdbFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = utcCalendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    /// Parses a string with format "yyyy-MM-dd" into a Date.
    static func parse(_ dateString: String?) -> Date? {
        guard let dateString else { return nil }
        let cleaned = dateString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return nil }
        return tmdbFormatter.date(from: cleaned)
    }

    /// Calculates age in years from a birthdate string ("yyyy-MM-dd") to today.
    static func calculateAge(from birthday: String) -> Int? {
        guard let birthDate = parse(birthday) else { return nil }
        return yearsBetween(start: birthDate, end: Date())
    }

    /// Calculates lived years between birth and death (both "yyyy-MM-dd").
    static func calculateYearsLived(birthday: String, deathday: String) -> Int? {
        guard let birthDate = parse(birthday),
              let deathDate = parse(deathday) else { return nil }
        return yearsBetween(start: birthDate, end: deathDate)
    }

    /// Returns the current year as a string, e.g., "2025".
    static func currentYearString() -> String {
        String(utcCalendar.component(.year, from: Date()))
    }

    /// Returns today's date as a string in "yyyy-MM-dd" format (TMDB compatible).
    static func todayString() -> String {
        tmdbFormatter.string(from: Date())
    }

    private static func yearsBetween(start: Date, end: Date) -> Int? {
        utcCalendar.dateComponents([.year], from: start, to: end).year
    }
}
