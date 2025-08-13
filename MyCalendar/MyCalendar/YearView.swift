//
//  YearView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 5. 8. 2025..
//

import SwiftUI

struct YearView: View {
    let year: Date
    let onMonthTapped: (Date) -> Void
    // --- It now also needs to know what to do when "Today" is tapped ---
    let onTodayTapped: () -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    private var years: [Date] {
        // ... this logic does not change ...
        let calendar = Calendar.current
        var result: [Date] = []
        let component = calendar.dateComponents([.year], from: year)
        guard let firstDayOfYear = calendar.date(from: component) else { return [] }

        for i in -10...10 {
            if let newYear = calendar.date(byAdding: .year, value: i, to: firstDayOfYear) {
                result.append(newYear)
            }
        }
        return result
    }
    
    private var yearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }

    var body: some View {
        // --- THIS IS THE NEW, STICKY HEADER ARCHITECTURE ---
        ScrollViewReader { proxy in
            ScrollView {
                // We use a LazyVStack with pinned headers.
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    // We wrap everything in a Section.
                    Section(header: YearHeaderView(year: year, onTodayTapped: onTodayTapped)) {
                        // This VStack holds all the years.
                        VStack(spacing: 30) {
                            ForEach(years) { yearDate in
                                // The header for each individual year (e.g., "2025")
                                Text(yearDate, formatter: yearFormatter)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.top)
                                
                                // The grid of 12 mini-months
                                LazyVGrid(columns: columns, spacing: 20) {
                                    ForEach(0..<12) { monthOffset in
                                        if let monthDate = Calendar.current.date(byAdding: .month, value: monthOffset, to: yearDate) {
                                            MiniMonthView(monthDate: monthDate) {
                                                onMonthTapped(monthDate)
                                            }
                                        }
                                    }
                                }
                                .id(yearDate) // ID for scrolling to this year
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .onAppear {
                // On appear, jump to the correct year.
                // We use a small delay to ensure the view is ready.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    proxy.scrollTo(year, anchor: .top)
                }
            }
        }
    }
}
