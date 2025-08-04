//  MonthView.swift

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
    let dayEntries: [DayEntry] // Pass in the fetched entries
    @Binding var selectedDate: Date?

    // No changes needed to this computed property
    private var weeks: [[CalendarDay]] {
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

    // --- CHANGE 1: Add a computed property to find the index of the last week of the month ---
    private var lastWeekOfMonthIndex: Int? {
        weeks.lastIndex { week in
            // This reuses our existing logic to find a week that contains a date in the current month
            weekContainsDateInCurrentMonth(week: week)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            MonthHeaderView(monthDate: monthDate)
            
            Divider().background(Color.gray.opacity(0.5))
            
            VStack(spacing: 0) {
                // --- CHANGE 2: Loop over the indices of the weeks array ---
                ForEach(weeks.indices, id: \.self) { weekIndex in
                    let week = weeks[weekIndex]
                    
                    HStack(spacing: 0) {
                        ForEach(week) { day in
                            if day.date == Date.distantPast {
                                Rectangle().fill(Color.clear)
                            } else {
                                DayCellView(day: day.date, dayEntry: dayEntries.first { Calendar.current.isDate($0.date, inSameDayAs: day.date) })
                                    .onTapGesture {
                                        self.selectedDate = day.date
                                    }
                            }
                        }
                    }

                    // --- CHANGE 3: The new and improved logic for drawing the divider ---
                    let isLastWeek = (weekIndex == lastWeekOfMonthIndex)
                    if weekContainsDateInCurrentMonth(week: week) && !isLastWeek {
                        Divider().background(Color.gray.opacity(0.5))
                    }
                }
            }
        }
    }
    
    // This helper function remains unchanged but is used by our new computed property
    private func weekContainsDateInCurrentMonth(week: [CalendarDay]) -> Bool {
        return week.contains { day in
            guard day.date != Date.distantPast else { return false }
            return Calendar.current.isDate(day.date, equalTo: monthDate, toGranularity: .month)
        }
    }
}
