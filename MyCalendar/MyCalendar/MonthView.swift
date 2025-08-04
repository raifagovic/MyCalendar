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
    let dayEntries: [DayEntry]
    @Binding var selectedDate: Date?

    // These computed properties remain the same and are correct.
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

    private var lastWeekOfMonthIndex: Int? {
        weeks.lastIndex { week in
            weekContainsDateInCurrentMonth(week: week)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            MonthHeaderView(monthDate: monthDate)
            
            Divider().background(Color.gray.opacity(0.5))
            
            // --- CHANGE 1: Revert from Grid back to VStack ---
            // This provides a much more stable layout container.
            VStack(spacing: 0) {
                ForEach(weeks.indices, id: \.self) { weekIndex in
                    let week = weeks[weekIndex]
                    
                    // The week of days is a simple, robust HStack.
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

                    // --- CHANGE 2: The divider logic is now inside the stable VStack ---
                    let isLastWeek = (weekIndex == lastWeekOfMonthIndex)
                    if weekContainsDateInCurrentMonth(week: week) && !isLastWeek {
                        
                        // The divider is its own HStack, guaranteeing it won't interfere
                        // with the layout of the day cells.
                        HStack(spacing: 0) {
                            if weeks.indices.contains(weekIndex + 1) {
                                let nextWeek = weeks[weekIndex + 1]
                                
                                ForEach(nextWeek) { dayInNextWeek in
                                    // If the day in the next row is a real date,
                                    // draw a segment of the divider line.
                                    if dayInNextWeek.date != .distantPast {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.5))
                                            .frame(height: 1)
                                    } else {
                                        // Otherwise, fill the space with clear.
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(height: 1)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func weekContainsDateInCurrentMonth(week: [CalendarDay]) -> Bool {
        return week.contains { day in
            guard day.date != Date.distantPast else { return false }
            return Calendar.current.isDate(day.date, equalTo: monthDate, toGranularity: .month)
        }
    }
}



