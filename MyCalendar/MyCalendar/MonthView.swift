//
//  MonthView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 31. 7. 2025..
//

import SwiftUI
import SwiftData

struct MonthView: View {
    let monthData: MonthData
    @Binding var selectedDate: Date?
    let onLongPressDay: (Date) -> Void

    private var monthDate: Date { monthData.id }

    private var firstDayOfCurrentMonth: CalendarDay? {
        monthData.weeks.flatMap { $0 }.first { day in
            guard day.date != .distantPast else { return false }
            return Calendar.current.isDate(day.date, equalTo: monthDate, toGranularity: .month)
                && Calendar.current.component(.day, from: day.date) == 1
        }
    }

    private var firstContentWeekIndex: Int? {
        monthData.weeks.firstIndex { week in
            week.contains { $0.date != .distantPast && Calendar.current.isDate($0.date, equalTo: monthDate, toGranularity: .month) }
        }
    }

    private var isCurrentMonth: Bool {
        Calendar.current.isDate(monthDate, equalTo: Date(), toGranularity: .month)
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(monthData.weeks.indices, id: \.self) { weekIndex in
                let week = monthData.weeks[weekIndex]

                WeekRowView(
                    week: week,
                    dayEntries: week.compactMap { $0.entry },
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
