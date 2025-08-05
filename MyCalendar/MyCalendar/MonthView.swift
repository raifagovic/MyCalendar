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

    private var weeks: [[CalendarDay]] {
        // This logic is correct and does not change.
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
    
    private var firstDayOfCurrentMonth: CalendarDay? {
        weeks.flatMap { $0 }.first { day in
            guard day.date != .distantPast else { return false }
            return Calendar.current.isDate(day.date, equalTo: monthDate, toGranularity: .month) &&
                   Calendar.current.component(.day, from: day.date) == 1
        }
    }
    
    private var monthAbbreviationFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }

    // --- CHANGE 1: Find the index of the first week that has real days for our month ---
    private var firstContentWeekIndex: Int? {
        weeks.firstIndex { week in
            week.contains { $0.date != .distantPast && Calendar.current.isDate($0.date, equalTo: monthDate, toGranularity: .month) }
        }
    }
    
    private var isCurrentMonth: Bool {
        Calendar.current.isDate(monthDate, equalTo: Date(), toGranularity: .month)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // --- CHANGE 2: THE NEW, CONSOLIDATED LOGIC ---
            ForEach(weeks.indices, id: \.self) { weekIndex in
                let week = weeks[weekIndex]

                // ** DIVIDER LOGIC **
                // We decide what to draw *above* the current week.
                
                // Case 1: Is this the very first week with content?
                if weekIndex == firstContentWeekIndex {
                    // If so, draw the special header with the line and the text.
                    ZStack {
                        // The divider line
                        HStack(spacing: 0) {
                            ForEach(week) { day in
                                Rectangle()
                                    .fill(day.date != .distantPast ? Color.gray.opacity(0.5) : Color.clear)
                                    .frame(height: 1)
                            }
                        }
                        // The month text, aligned perfectly
                        HStack(spacing: 0) {
                            ForEach(week) { day in
                                if day.date != .distantPast && Calendar.current.component(.day, from: day.date) == 1 {
                                    Text(monthAbbreviationFormatter.string(from: monthDate))
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(isCurrentMonth ? .red : .primary)
                                        .offset(y: -15)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                } else {
                                    Color.clear
                                }
                            }
                        }
                    }
                }
                // Case 2: Is this a *later* week that has content?
                else if weekIndex > (firstContentWeekIndex ?? -1) && week.contains(where: { $0.date != .distantPast }) {
                    // If so, draw a simple divider line.
                    HStack(spacing: 0) {
                        ForEach(week) { day in
                            Rectangle()
                                .fill(day.date != .distantPast ? Color.gray.opacity(0.5) : Color.clear)
                                .frame(height: 1)
                        }
                    }
                }
                
                // ** WEEK CONTENT **
                // After handling the divider, always draw the row of days.
                WeekRowView(week: week, dayEntries: dayEntries, selectedDate: $selectedDate)
            }
        }
    }
}



