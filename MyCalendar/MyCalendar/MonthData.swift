//
//  MonthData.swift
//  MyCalendar
//
//  Created by Raif Agovic on 21. 10. 2025..
//

import Foundation

struct MonthData: Identifiable, Equatable {
    let id: Date // the month start date
    let weeks: [[CalendarDay]]

    static func generate(for monthDate: Date, dayEntries: [DayEntry]) -> MonthData {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else {
            return MonthData(id: monthDate, weeks: [])
        }

        var allDays: [CalendarDay] = []
        let firstDay = monthInterval.start

        // Empty cells before the first of the month
        let emptyDays = (calendar.component(.weekday, from: firstDay) - calendar.firstWeekday + 7) % 7
        for _ in 0..<emptyDays {
            allDays.append(CalendarDay(date: .distantPast, entry: nil))
        }

        // Real days
        if let range = calendar.range(of: .day, in: .month, for: monthDate) {
            for dayNumber in range {
                if let date = calendar.date(byAdding: .day, value: dayNumber - 1, to: firstDay) {
                    let entry = dayEntries.first(where: {
                        Calendar.current.isDate($0.date, inSameDayAs: date)
                    })
                    allDays.append(CalendarDay(date: date, entry: entry))
                }
            }
        }

        // Trailing blanks
        while allDays.count % 7 != 0 {
            allDays.append(CalendarDay(date: .distantPast, entry: nil))
        }

        // Split into weeks
        var resultWeeks: [[CalendarDay]] = []
        for chunk in stride(from: 0, to: allDays.count, by: 7) {
            resultWeeks.append(Array(allDays[chunk..<min(chunk + 7, allDays.count)]))
        }
        while resultWeeks.count < 6 {
            resultWeeks.append(Array(repeating: CalendarDay(date: .distantPast, entry: nil), count: 7))
        }

        return MonthData(id: monthDate.startOfMonth, weeks: resultWeeks)
    }
}
