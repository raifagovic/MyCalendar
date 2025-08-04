
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
    let firstDayOfCurrentMonth: CalendarDay?
    let monthAbbreviation: String
    let monthDate: Date

    var body: some View {
        VStack(spacing: 0) {
            // The logic for drawing the divider line itself
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
                // --- CHANGE: ADD THE OVERLAY TO THE DIVIDER HSTACK ---
                .overlay(
                    // This HStack acts as a guide to position our text
                    HStack(spacing: 0) {
                        ForEach(week) { day in
                            // If this column contains the first day of the month...
                            if day.id == firstDayOfCurrentMonth?.id {
                                // ...draw the abbreviation text here.
                                Text(monthAbbreviation)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                    .textCase(.uppercase)
                                    .padding(.bottom, 2) // Push text slightly above the line
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                // Otherwise, fill the space with a clear view.
                                Color.clear
                            }
                        }
                    }
                )
            }
            
            // The row of day cells (no changes needed here)
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
            guard day.date != Date.distantPast else { return false }
            return Calendar.current.isDate(day.date, equalTo: monthDate, toGranularity: .month)
        }
    }
}
