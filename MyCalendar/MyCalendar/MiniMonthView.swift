//
//  MiniMonthView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 5. 8. 2025..
//

import SwiftUI

struct MiniMonthView: View {
    let monthDate: Date
    let onTapped: () -> Void
    
    // A 7-column grid for the days of the week
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    // This is the same logic from MonthView, but simplified for this purpose.
    private var days: [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else { return [] }
        
        var allDays: [Date] = []
        let firstDay = monthInterval.start
        
        // Use the localized first weekday for correct layout
        let emptyDays = (calendar.component(.weekday, from: firstDay) - calendar.firstWeekday + 7) % 7
        
        allDays.append(contentsOf: Array(repeating: Date.distantPast, count: emptyDays))
        
        if let range = calendar.range(of: .day, in: .month, for: monthDate) {
            let realDays = range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: firstDay) }
            allDays.append(contentsOf: realDays)
        }
        return allDays
    }
    
    private var monthAbbreviationFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }

    var body: some View {
        Button(action: onTapped) {
            VStack(spacing: 5) {
                // Month Header (e.g., "Sep")
                Text(monthDate, formatter: monthAbbreviationFormatter)
                    .font(.headline)
                    .foregroundColor(Calendar.current.isDateInThisMonth(monthDate) ? .red : .primary)
                
                // The grid of day numbers
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(days.indices, id: \.self) { index in
                        let day = days[index]
                        
                        if day == Date.distantPast {
                            Text("") // Empty cell
                        } else {
                            Text("\(Calendar.current.component(.day, from: day))")
                                .font(.caption2)
                                .foregroundColor(Calendar.current.isDateInToday(day) ? .red : .secondary)
                        }
                    }
                }
            }
        }
    }
}
