
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

    // --- All this setup code is still needed to pass down to WeekRowView ---
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

    private var firstDayOfCurrentMonth: CalendarDay? {
        weeks.flatMap { $0 }.first { day in
            guard day.date != .distantPast else { return false }
            return Calendar.current.isDate(day.date, equalTo: monthDate, toGranularity: .month) &&
                   Calendar.current.component(.day, from: day.date) == 1
        }
    }
    
    // --- THIS LOGIC STAYS HERE, AS IT APPLIES TO THE WHOLE MONTH ---
    private var firstContentWeekIndex: Int? {
        weeks.firstIndex { week in
            week.contains { $0.date != .distantPast && Calendar.current.isDate($0.date, equalTo: monthDate, toGranularity: .month) }
        }
    }
    
    private var isCurrentMonth: Bool {
        Calendar.current.isDate(monthDate, equalTo: Date(), toGranularity: .month)
    }
    
//    var body: some View {
//        VStack(spacing: 0) {
//            ForEach(weeks.indices, id: \.self) { weekIndex in
//                let week = weeks[weekIndex]
//                
//                // We just pass all the necessary data to WeekRowView and let it handle the rest.
//                WeekRowView(
//                    week: week,
//                    dayEntries: dayEntries,
//                    selectedDate: $selectedDate,
//                    monthDate: monthDate,
//                    isFirstContentWeek: weekIndex == firstContentWeekIndex,
//                    firstDayOfCurrentMonth: self.firstDayOfCurrentMonth
//                )
//            }
//        }
//        .padding(.top, isCurrentMonth ? 135 : 0)
//    }
    
    var body: some View {
        VStack(spacing: 0) {
            // NEW: Add an invisible view here for scrolling *only if* it's the current month
            // This view will represent the top of the calendar grid, adjusting for the 135 padding.
            if isCurrentMonth {
                Color.clear
                    .frame(height: 0) // It takes no visual space
                    .id(monthDate.gridStartID) // Give it a unique ID for scrolling
                    .padding(.top, 135) // Apply the padding *above* this clear view, not on the entire VStack
            }
            
            ForEach(weeks.indices, id: \.self) { weekIndex in
                let week = weeks[weekIndex]
                
                WeekRowView(
                    week: week,
                    dayEntries: dayEntries,
                    selectedDate: $selectedDate,
                    monthDate: monthDate,
                    isFirstContentWeek: weekIndex == firstContentWeekIndex,
                    firstDayOfCurrentMonth: self.firstDayOfCurrentMonth
                )
            }
        }
        // REMOVE THE PADDING FROM THE VStack ITSELF. It's now applied to the invisible scroll target.
        // .padding(.top, isCurrentMonth ? 135 : 0) // <-- REMOVE THIS LINE!
    }
}
