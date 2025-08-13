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
    let onTodayTapped: () -> Void
    
    // --- THE FIX: Change from 2 to 3 GridItems ---
    private let columns = [
        GridItem(.flexible(), spacing: 10), // Reduced spacing for a tighter grid
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    // ... (the rest of the file is unchanged) ...
    private var years: [Date] {
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
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section(header: YearHeaderView(year: year, onTodayTapped: onTodayTapped)) {
                        VStack(spacing: 30) {
                            ForEach(years) { yearDate in
                                Section(header: Text(yearDate, formatter: yearFormatter).font(.title).fontWeight(.bold).padding(.top)) {
                                    LazyVGrid(columns: columns, spacing: 20) { // Keep spacing here for rows
                                        ForEach(0..<12) { monthOffset in
                                            if let monthDate = Calendar.current.date(byAdding: .month, value: monthOffset, to: yearDate) {
                                                MiniMonthView(monthDate: monthDate) {
                                                    onMonthTapped(monthDate)
                                                }
                                            }
                                        }
                                    }
                                }
                                .id(yearDate)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    proxy.scrollTo(year, anchor: .top)
                }
            }
        }
    }
}
