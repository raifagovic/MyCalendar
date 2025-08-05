//
//  WeekRowView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 4. 8. 2025..
//

import SwiftUI
import SwiftData

struct WeekRowView: View {
    let week: [CalendarDay]
    let dayEntries: [DayEntry]
    @Binding var selectedDate: Date?
    
    // --- CHANGE 1: Simplified properties ---
    let isFirstWeekOfMonth: Bool
    let monthDate: Date

    var body: some View {
        VStack(spacing: 0) {
            // --- CHANGE 2: Simplified Divider Logic ---
            // Only draw a divider if this is NOT the first week, but still a week with content.
            if !isFirstWeekOfMonth && weekContainsDateInCurrentMonth(week: week) {
                HStack(spacing: 0) {
                    ForEach(week) { day in
                        Rectangle()
                            .fill(day.date != .distantPast ? Color.gray.opacity(0.5) : Color.clear)
                            .frame(height: 1)
                    }
                }
            }
            
            // The row of day cells (this is now its main job)
            HStack(spacing: 0) {
                ForEach(week) { day in
                    if day.date == Date.distantPast {
                        Rectangle().fill(Color.clear)
                    } else {
                        DayCellView(
                            day: day.date,
                            dayEntry: dayEntries.first { Calendar.current.isDate($0.date, inSameDayAs: day.date) }
                        )
                        .onTapGesture {
                            self.selectedDate = day.date
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
