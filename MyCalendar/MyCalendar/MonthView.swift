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

import SwiftUI
import SwiftData

struct MonthView: View {
    let monthDate: Date
    // REMOVE THIS: let dayEntries: [DayEntry] // ❌ DELETE THIS LINE
    @Binding var selectedDate: Date?
    let onLongPressDay: (Date) -> Void
    
    @Environment(\.modelContext) private var modelContext // ✅ Inject modelContext here
    
    // ✅ NEW: Query for day entries relevant to this specific month
    @Query var dayEntriesForMonth: [DayEntry]
    
    @State private var weeks: [[CalendarDay]] = []
    
    // Add an initializer to compute weeks once or update when dependencies change
    // Modified initializer
    init(monthDate: Date, selectedDate: Binding<Date?>, onLongPressDay: @escaping (Date) -> Void) {
        self.monthDate = monthDate
        self._selectedDate = selectedDate
        self.onLongPressDay = onLongPressDay
        
        // Create a predicate to filter entries for this month
        let calendar = Calendar.current
        let startOfMonth = monthDate.startOfMonth // Using your Date extension
        // Calculate the end of the month properly (start of next month - 1 day)
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        let endOfMonth = calendar.date(byAdding: .day, value: -1, to: nextMonth)!

        let predicate = #Predicate<DayEntry> { entry in
            entry.date >= startOfMonth && entry.date <= endOfMonth
        }
        _dayEntriesForMonth = Query(filter: predicate, sort: \.date)
        
        // Initialize weeks with empty array; it will be filled in onAppear and onChange
        _weeks = State(initialValue: [])
    }
    
    private static func generateWeeks(monthDate: Date, dayEntries: [DayEntry]) -> [[CalendarDay]] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else { return [] }
        
        var allDays: [CalendarDay] = []
        let firstDay = monthInterval.start
        
        let emptyDays = (calendar.component(.weekday, from: firstDay) - calendar.firstWeekday + 7) % 7
        
        for _ in 0..<emptyDays {
            allDays.append(CalendarDay(date: .distantPast, entry: nil))
        }
        
        if let range = calendar.range(of: .day, in: .month, for: monthDate) {
            for dayNumber in range {
                if let date = calendar.date(byAdding: .day, value: dayNumber - 1, to: firstDay) {
                    // Optimized: Use the filtered dayEntriesForMonth
                    let entry = dayEntries.first(where: { $0.date.isSameDay(as: date) })
                    allDays.append(CalendarDay(date: date, entry: entry))
                }
            }
        }
        
        while allDays.count % 7 != 0 {
            allDays.append(CalendarDay(date: .distantPast, entry: nil))
        }
        
        var resultWeeks: [[CalendarDay]] = []
        for chunk in stride(from: 0, to: allDays.count, by: 7) {
            resultWeeks.append(Array(allDays[chunk..<min(chunk + 7, allDays.count)]))
        }
        while resultWeeks.count < 6 {
            resultWeeks.append(Array(repeating: CalendarDay(date: .distantPast, entry: nil), count: 7))
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

    private var firstContentWeekIndex: Int? {
        weeks.firstIndex { week in
            week.contains { $0.date != .distantPast && Calendar.current.isDate($0.date, equalTo: monthDate, toGranularity: .month) }
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
                    dayEntries: dayEntriesForMonth, // ✅ Pass the month-specific entries
                    selectedDate: $selectedDate,
                    monthDate: monthDate,
                    isFirstContentWeek: weekIndex == firstContentWeekIndex,
                    firstDayOfCurrentMonth: self.firstDayOfCurrentMonth,
                    onLongPressDay: onLongPressDay
                )
            }
        }
        .padding(.top, isCurrentMonth ? 135 : 0)
        // ✅ NEW: Update weeks when dayEntriesForMonth changes (reactive)
        .onAppear {
            weeks = Self.generateWeeks(monthDate: monthDate, dayEntries: dayEntriesForMonth)
        }
        .onChange(of: dayEntriesForMonth) {
            weeks = Self.generateWeeks(monthDate: monthDate, dayEntries: dayEntriesForMonth)
        }
    }
}

// ... rest of file (CalendarDay struct) ...
