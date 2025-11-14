//
//  MonthView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 31. 7. 2025..
//

//import SwiftUI
//import SwiftData
//
//struct MonthView: View {
//    let monthDate: Date
//    let dayEntries: [DayEntry]
//    @Binding var selectedDate: Date?
//    let onLongPressDay: (Date) -> Void
//    
//    @State private var weeks: [[CalendarDay]] = []
//    
//    // Add an initializer to compute weeks once or update when dependencies change
//    init(monthDate: Date, dayEntries: [DayEntry], selectedDate: Binding<Date?>, onLongPressDay: @escaping (Date) -> Void) {
//        self.monthDate = monthDate
//        self.dayEntries = dayEntries
//        self._selectedDate = selectedDate
//        self.onLongPressDay = onLongPressDay
//        _weeks = State(initialValue: Self.generateWeeks(monthDate: monthDate, dayEntries: dayEntries))
//    }
//    
//    // Add a static helper to generate weeks to be called from init and onChange
//    private static func generateWeeks(monthDate: Date, dayEntries: [DayEntry]) -> [[CalendarDay]] {
//        let calendar = Calendar.current
//        guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else { return [] }
//        
//        var allDays: [CalendarDay] = []
//        let firstDay = monthInterval.start
//        
//        let emptyDays = (calendar.component(.weekday, from: firstDay) - calendar.firstWeekday + 7) % 7
//        
//        for _ in 0..<emptyDays {
//            allDays.append(CalendarDay(date: .distantPast, entry: nil))
//        }
//        
//        if let range = calendar.range(of: .day, in: .month, for: monthDate) {
//            for dayNumber in range {
//                if let date = calendar.date(byAdding: .day, value: dayNumber - 1, to: firstDay) {
//                    let entry = dayEntries.first(where: { $0.date.isSameDay(as: date) })
//                    allDays.append(CalendarDay(date: date, entry: entry))
//                }
//            }
//        }
//        
//        while allDays.count % 7 != 0 {
//            allDays.append(CalendarDay(date: .distantPast, entry: nil))
//        }
//        
//        var resultWeeks: [[CalendarDay]] = []
//        for chunk in stride(from: 0, to: allDays.count, by: 7) {
//            resultWeeks.append(Array(allDays[chunk..<min(chunk + 7, allDays.count)]))
//        }
//        while resultWeeks.count < 6 {
//            resultWeeks.append(Array(repeating: CalendarDay(date: .distantPast, entry: nil), count: 7))
//        }
//        return resultWeeks
//    }
//
//
//    private var firstDayOfCurrentMonth: CalendarDay? {
//        weeks.flatMap { $0 }.first { day in
//            guard day.date != .distantPast else { return false }
//            return Calendar.current.isDate(day.date, equalTo: monthDate, toGranularity: .month) &&
//                   Calendar.current.component(.day, from: day.date) == 1
//        }
//    }
//
//    private var firstContentWeekIndex: Int? {
//        weeks.firstIndex { week in
//            week.contains { $0.date != .distantPast && Calendar.current.isDate($0.date, equalTo: monthDate, toGranularity: .month) }
//        }
//    }
//
//    private var isCurrentMonth: Bool {
//            monthDate.isSameMonth(as: Date())
//        }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            ForEach(weeks.indices, id: \.self) { weekIndex in
//                let week = weeks[weekIndex]
//                
//                WeekRowView(
//                    week: week,
//                    dayEntries: dayEntries,
//                    selectedDate: $selectedDate,
//                    monthDate: monthDate,
//                    isFirstContentWeek: weekIndex == firstContentWeekIndex,
//                    firstDayOfCurrentMonth: self.firstDayOfCurrentMonth,
//                    onLongPressDay: onLongPressDay
//                )
//            }
//        }
//        .padding(.top, isCurrentMonth ? 135 : 0)
//    }
//}

// MonthView.swift
import SwiftUI
import SwiftData

struct MonthView: View {
    let monthDate: Date
    // Use dictionary lookup for O(1) DayEntry access
    let entriesByDate: [Date: DayEntry]
    @Binding var selectedDate: Date?
    let onLongPressDay: (Date) -> Void
    
    // weeks computed once in init and stored as an immutable property
    private let weeks: [[CalendarDay]]
    
    init(monthDate: Date,
         entriesByDate: [Date: DayEntry],
         selectedDate: Binding<Date?>,
         onLongPressDay: @escaping (Date) -> Void) {
        
        self.monthDate = monthDate
        self.entriesByDate = entriesByDate
        self._selectedDate = selectedDate
        self.onLongPressDay = onLongPressDay
        self.weeks = Self.generateWeeks(monthDate: monthDate, entriesByDate: entriesByDate)
    }
    
    private static func generateWeeks(monthDate: Date, entriesByDate: [Date: DayEntry]) -> [[CalendarDay]] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else { return [] }
        var allDays: [CalendarDay] = []
        let firstDay = monthInterval.start
        
        let emptyDays = (calendar.component(.weekday, from: firstDay) - calendar.firstWeekday + 7) % 7
        for _ in 0..<emptyDays {
            allDays.append(CalendarDay.empty)
        }
        
        if let range = calendar.range(of: .day, in: .month, for: monthDate) {
            for dayNumber in range {
                if let date = calendar.date(byAdding: .day, value: dayNumber - 1, to: firstDay) {
                    let key = date.startOfDay
                    let entry = entriesByDate[key]
                    allDays.append(CalendarDay(date: date, entry: entry))
                }
            }
        }
        
        while allDays.count % 7 != 0 {
            allDays.append(CalendarDay.empty)
        }
        
        var resultWeeks: [[CalendarDay]] = []
        for chunkStart in stride(from: 0, to: allDays.count, by: 7) {
            resultWeeks.append(Array(allDays[chunkStart..<min(chunkStart + 7, allDays.count)]))
        }
        while resultWeeks.count < 6 {
            resultWeeks.append(Array(repeating: CalendarDay.empty, count: 7))
        }
        return resultWeeks
    }
    
    private var firstContentWeekIndex: Int? {
        weeks.firstIndex { week in
            week.contains { $0.isRealDay && Calendar.current.isDate($0.date, equalTo: monthDate, toGranularity: .month) }
        }
    }

    private var firstDayOfCurrentMonth: CalendarDay? {
        weeks.flatMap { $0 }.first { day in
            day.isRealDay && Calendar.current.isDate(day.date, equalTo: monthDate, toGranularity: .month) &&
            Calendar.current.component(.day, from: day.date) == 1
        }
    }

    private var isCurrentMonth: Bool {
        monthDate.isSameMonth(as: Date())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(weeks.indices, id: \.self) { weekIndex in
                let week = weeks[weekIndex]
                WeekRowView(
                    week: week,
                    selectedDate: $selectedDate,
                    monthDate: monthDate,
                    isFirstContentWeek: weekIndex == firstContentWeekIndex,
                    firstDayOfCurrentMonth: firstDayOfCurrentMonth,
                    onLongPressDay: onLongPressDay
                )
            }
        }
        // only add large top padding for the current month once
        .padding(.top, isCurrentMonth ? 135 : 0)
    }
}
