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
        // ... (this logic is unchanged and correct)
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

    var body: some View {
        VStack(spacing: 0) {
            
            // --- CHANGE 1: THE NEW SMART HEADER ---
            // Find the very first week that contains a day from our month.
            if let firstWeek = weeks.first(where: { week in week.contains { $0.date != .distantPast && Calendar.current.isDate($0.date, equalTo: monthDate, toGranularity: .month) } }) {
                
                // Use a ZStack for layering the line and the text
                ZStack {
                    // Layer 1: The partial divider line
                    HStack(spacing: 0) {
                        ForEach(firstWeek) { day in
                            Rectangle()
                                .fill(day.date != .distantPast ? Color.gray.opacity(0.5) : Color.clear)
                                .frame(height: 1)
                        }
                    }
                    
                    // Layer 2: The Month Abbreviation Text
                    HStack(spacing: 0) {
                        ForEach(firstWeek) { day in
                            if day.id == firstDayOfCurrentMonth?.id {
                                Text(monthAbbreviationFormatter.string(from: monthDate))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                    .textCase(.uppercase)
                                    .padding(.bottom, 2) // Lifts text slightly above the line
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                Color.clear
                            }
                        }
                    }
                }
            }
            
            // --- CHANGE 2: THE LOOP FOR ALL WEEKS ---
            ForEach(weeks.indices, id: \.self) { weekIndex in
                let week = weeks[weekIndex]
                
                // Pass a flag to WeekRowView to tell it if it's the first week
                let isFirstContentWeek = (week.first { $0.id == firstDayOfCurrentMonth?.id } != nil)
                
                WeekRowView(
                    week: week,
                    dayEntries: dayEntries,
                    selectedDate: $selectedDate,
                    isFirstWeekOfMonth: isFirstContentWeek,
                    monthDate: monthDate // Pass monthDate for helper logic
                )
            }
        }
    }
}



