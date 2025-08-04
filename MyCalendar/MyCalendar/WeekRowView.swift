
//
//  WeekRowView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 4. 8. 2025..
//

import SwiftUI
import SwiftData // Needed for DayEntry

struct WeekRowView: View {
    let week: [CalendarDay]
    let dayEntries: [DayEntry]
    @Binding var selectedDate: Date?
    let firstDayOfCurrentMonth: CalendarDay?
    let monthAbbreviation: String
    let monthDate: Date

    var body: some View {
        VStack(spacing: 0) {
            // The divider logic for the week
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
            
            // The row of day cells
            HStack(spacing: 0) {
                ForEach(week) { day in
                    if day.date == Date.distantPast {
                        Rectangle().fill(Color.clear)
                    } else {
                        DayCellView(
                            day: day.date,
                            dayEntry: dayEntries.first { Calendar.current.isDate($0.date, inSameDayAs: day.date) },
                            isFirstDayOfMonth: day.id == firstDayOfCurrentMonth?.id,
                            monthAbbreviation: monthAbbreviation
                        )
                        .onTapGesture {
                            self.selectedDate = day.date
                        }
                    }
                }
            }
        }
    }

    // Helper function specific to this view
    private func weekContainsDateInCurrentMonth(week: [CalendarDay]) -> Bool {
        return week.contains { day in
            guard day.date != Date.distantPast else { return false }
            return Calendar.current.isDate(day.date, equalTo: monthDate, toGranularity: .month)
        }
    }
}
