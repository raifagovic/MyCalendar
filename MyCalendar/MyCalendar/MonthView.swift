//
//  MonthView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 31. 7. 2025..
//

import SwiftUI
import SwiftData

struct MonthView: View {
    let monthDate: Date
    let dayEntries: [DayEntry]
    @Binding var selectedDate: Date?

    // The 'weeks' computed property does not need any changes.
    private var weeks: [[CalendarDay]] {
        // ... (logic is unchanged)
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else { return [] }
        var allDays: [CalendarDay] = []
        let firstDay = monthInterval.start
        let emptyDays = (calendar.component(.weekday, from: firstDay) - calendar.firstWeekday + 7) % 7
        for _ in 0..<emptyDays {
            allDays.append(CalendarDay(date: .distantPast))
        }
        if let range = calendar.range(of: .day, in: .month, for: monthDate) {
            let realDays = range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: firstDay) }
            for day in realDays {
                allDays.append(CalendarDay(date: day))
            }
        }
        var resultWeeks = [[CalendarDay]]()
        var currentWeek: [CalendarDay] = []
        for day in allDays {
            currentWeek.append(day)
            if currentWeek.count == 7 {
                resultWeeks.append(currentWeek)
                currentWeek = []
            }
        }
        if !currentWeek.isEmpty {
            let remaining = 7 - currentWeek.count
            for _ in 0..<remaining {
                currentWeek.append(CalendarDay(date: .distantPast))
            }
            resultWeeks.append(currentWeek)
        }
        while resultWeeks.count < 6 {
            var paddingWeek: [CalendarDay] = []
            for _ in 0..<7 {
                paddingWeek.append(CalendarDay(date: .distantPast))
            }
            resultWeeks.append(paddingWeek)
        }
        return resultWeeks
    }

    // --- CHANGE 1: Helper to find the first day ---
    private var firstDayOfCurrentMonth: CalendarDay? {
        weeks.flatMap { $0 }.first { day in
            guard day.date != .distantPast else { return false }
            return Calendar.current.isDate(day.date, equalTo: monthDate, toGranularity: .month) &&
                   Calendar.current.component(.day, from: day.date) == 1
        }
    }
    
    // --- CHANGE 2: Formatter for the abbreviation ---
    private var monthAbbreviationFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }

    var body: some View {
        VStack(spacing: 0) {
            // --- THIS IS THE CORRECTED LINE ---
            ForEach(weeks.indices, id: \.self) { weekIndex in
                let week = weeks[weekIndex]
                
                // The divider logic is correct
                if weekContainsDateInCurrentMonth(week: week) {
                    HStack(spacing: 0) {
                        ForEach(week) { day in
                            if day.date != .distantPast {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(height: 1)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 1)
                            }
                        }
                    }
                }
                
                // The day cell logic is correct
                HStack(spacing: 0) {
                    ForEach(week) { day in
                        if day.date == Date.distantPast {
                            Rectangle().fill(Color.clear)
                        } else {
                            DayCellView(
                                day: day.date,
                                dayEntry: dayEntries.first { Calendar.current.isDate($0.date, inSameDayAs: day.date) },
                                isFirstDayOfMonth: day.id == firstDayOfCurrentMonth?.id,
                                monthAbbreviation: monthDate.formatted(monthAbbreviationFormatter)
                            )
                            .onTapGesture {
                                self.selectedDate = day.date
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func weekContainsDateInCurrentMonth(week: [CalendarDay]) -> Bool {
        return week.contains { day in
            guard day.date != .distantPast else { return false }
            return Calendar.current.isDate(day.date, equalTo: monthDate, toGranularity: .month)
        }
    }
}



