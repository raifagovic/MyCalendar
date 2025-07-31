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

    private var weeks: [[Date]] {
        // This logic calculates the grid for the specific monthDate
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else { return [] }
        var allDays: [Date] = []
        let firstDay = monthInterval.start
        let emptyDays = (calendar.component(.weekday, from: firstDay) - calendar.firstWeekday + 7) % 7
        allDays.append(contentsOf: Array(repeating: Date.distantPast, count: emptyDays))
        if let range = calendar.range(of: .day, in: .month, for: monthDate) {
            allDays.append(contentsOf: range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: firstDay) })
        }
        var resultWeeks = [[Date]]()
        var currentWeek: [Date] = []
        for day in allDays {
            currentWeek.append(day)
            if currentWeek.count == 7 {
                resultWeeks.append(currentWeek)
                currentWeek = []
            }
        }
        if !currentWeek.isEmpty {
            currentWeek.append(contentsOf: Array(repeating: Date.distantPast, count: 7 - currentWeek.count))
            resultWeeks.append(currentWeek)
        }
        while resultWeeks.count < 6 {
            resultWeeks.append(Array(repeating: Date.distantPast, count: 7))
        }
        return resultWeeks
    }

    var body: some View {
        VStack(spacing: 0) {
            MonthHeaderView(monthDate: monthDate)
            
            Divider().background(Color.gray.opacity(0.5))
            
            VStack(spacing: 0) {
                ForEach(weeks, id: \.self) { week in
                    HStack(spacing: 0) {
                        ForEach(week, id: \.self) { day in
                            if day == Date.distantPast {
                                Rectangle().fill(Color.clear)
                            } else {
                                DayCellView(day: day, dayEntry: dayEntries.first { Calendar.current.isDate($0.date, inSameDayAs: day) })
                                    .onTapGesture {
                                        self.selectedDate = day
                                    }
                            }
                        }
                    }
                    if weekContainsDateInCurrentMonth(week: week) {
                        Divider().background(Color.gray.opacity(0.5))
                    }
                }
            }
        }
    }
    
    private func weekContainsDateInCurrentMonth(week: [Date]) -> Bool {
        return week.contains { day in
            guard day != Date.distantPast else { return false }
            return Calendar.current.isDate(day, equalTo: monthDate, toGranularity: .month)
        }
    }
}
