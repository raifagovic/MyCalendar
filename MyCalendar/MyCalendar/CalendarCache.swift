//
//  CalendarCache.swift
//  MyCalendar
//
//  Created by Raif Agovic on 14. 11. 2025..
//

import Foundation

struct CalendarCache {

    /// Precomputed list of 20 years of months (10 years back + 10 years forward)
    static let months: [Date] = {
        generateMonths()
    }()

    /// Generates a list of the first day of each month for a 20-year span
    private static func generateMonths() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        let currentYear = calendar.component(.year, from: today)

        let yearsRange = (currentYear - 10)...(currentYear + 10)

        return yearsRange.flatMap { year in
            (1...12).compactMap { month in
                calendar.date(from: DateComponents(year: year, month: month, day: 1))
            }
        }
    }
}
