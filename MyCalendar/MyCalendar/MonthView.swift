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
//    let dayEntries: [DayEntry]
    @Binding var selectedDate: Date?
    let onLongPressDay: (Date) -> Void

    private var firstDayOfCurrentMonth: CalendarDay? {
        weeks.flatMap { $0 }.first { day in
            guard day.date != .distantPast else { return false }
            return Calendar.current.isDate(day.date, equalTo: monthDate, toGranularity: .month) &&
                   Calendar.current.component(.day, from: day.date) == 1
        }
    }

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
            ForEach(weeks.indices, id: \.self) { weekIndex in
                let week = weeks[weekIndex]
                
                WeekRowView(
                    week: week,
                    dayEntries: dayEntries,
                    selectedDate: $selectedDate,
                    monthDate: monthDate,
                    isFirstContentWeek: weekIndex == firstContentWeekIndex,
                    firstDayOfCurrentMonth: self.firstDayOfCurrentMonth,
                    onLongPressDay: onLongPressDay
                )
            }
        }
        .padding(.top, isCurrentMonth ? 135 : 0)
    }
}
