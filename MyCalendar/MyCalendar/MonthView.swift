//  MonthView.swift

import SwiftUI
import SwiftData

struct MonthView: View {
    let monthDate: Date
    let dayEntries: [DayEntry]
    @Binding var selectedDate: Date?

    // --- CHANGE #1: The return type is now [[CalendarDay]] ---
    private var weeks: [[CalendarDay]] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else { return [] }
        
        var allDays: [CalendarDay] = [] // The array now holds CalendarDay objects
        
        let firstDay = monthInterval.start
        let emptyDays = (calendar.component(.weekday, from: firstDay) - calendar.firstWeekday + 7) % 7
        
        // --- CHANGE #2: Create CalendarDay objects for empty days ---
        for _ in 0..<emptyDays {
            allDays.append(CalendarDay(date: .distantPast))
        }

        // --- CHANGE #3: Create CalendarDay objects for real days ---
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
                currentWeek.append(CalendarDay(date: .distantPast)) // Create more empty days
            }
            resultWeeks.append(currentWeek)
        }
        
        // This logic is now safer as each CalendarDay has a unique ID
        while resultWeeks.count < 6 {
            var paddingWeek: [CalendarDay] = []
            for _ in 0..<7 {
                paddingWeek.append(CalendarDay(date: .distantPast))
            }
            resultWeeks.append(paddingWeek)
        }
        
        return resultWeeks
    }

    var body: some View {
        VStack(spacing: 0) {
            MonthHeaderView(monthDate: monthDate)
            
            Divider().background(Color.gray.opacity(0.5))
            
            VStack(spacing: 0) {
                // --- CHANGE #4: The ForEach now iterates over CalendarDay arrays ---
                ForEach(weeks, id: \.self) { week in
                    HStack(spacing: 0) {
                        // The inner ForEach now uses the unique ID of the CalendarDay
                        ForEach(week) { day in // No need for `id: \.self` anymore
                            if day.date == Date.distantPast {
                                Rectangle().fill(Color.clear)
                            } else {
                                // --- CHANGE #5: Pass the date from the day object ---
                                DayCellView(day: day.date, dayEntry: dayEntries.first { Calendar.current.isDate($0.date, inSameDayAs: day.date) })
                                    .onTapGesture {
                                        self.selectedDate = day.date
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
    
    // --- CHANGE #6: Update the helper function ---
    private func weekContainsDateInCurrentMonth(week: [CalendarDay]) -> Bool {
        return week.contains { day in
            guard day.date != Date.distantPast else { return false }
            return Calendar.current.isDate(day.date, equalTo: monthDate, toGranularity: .month)
        }
    }
}
