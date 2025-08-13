//
//  YearView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 5. 8. 2025..
//

import SwiftUI

struct YearView: View {
    // The starting year to display
    let year: Date
    // The action to perform when a month is tapped
    let onMonthTapped: (Date) -> Void
    
    // A 2-column grid for a more spacious layout
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    // Generate a range of years to scroll through
    private var years: [Date] {
        let calendar = Calendar.current
        var result: [Date] = []
        let component = calendar.dateComponents([.year], from: year)
        guard let firstDayOfYear = calendar.date(from: component) else { return [] }

        // Generate 10 years past and 10 years future
        for i in -10...10 {
            if let newYear = calendar.date(byAdding: .year, value: i, to: firstDayOfYear) {
                result.append(newYear)
            }
        }
        return result
    }
    
    // Formatters for the year and month headers
    private var yearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }

    private var monthAbbreviationFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }

    var body: some View {
        // --- THIS VIEW IS NOW A SCROLLABLE LIST OF YEARS ---
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 30) {
                    ForEach(years) { yearDate in
                        Section(header: Text(yearDate, formatter: yearFormatter).font(.title).fontWeight(.bold).padding(.top)) {
                            // A grid that contains 12 mini-months
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(0..<12) { monthOffset in
                                    if let monthDate = Calendar.current.date(byAdding: .month, value: monthOffset, to: yearDate) {
                                        MiniMonthView(monthDate: monthDate) {
                                            // When tapped, perform the action from CalendarView
                                            onMonthTapped(monthDate)
                                        }
                                    }
                                }
                            }
                        }
                        .id(yearDate) // ID for scrolling
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                // On appear, jump to the current year
                proxy.scrollTo(year, anchor: .center)
            }
        }
    }
}
