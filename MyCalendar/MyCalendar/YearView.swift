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
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    @State private var years: [Date] = []
    
    private var yearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section(header: YearHeaderView(onTodayTapped: onTodayTapped)) {
                        // This is the container for all the years.
                        VStack(spacing: 30) { // This spacing now works predictably.
                            ForEach(years) { yearDate in
                                // --- THE DEFINITIVE FIX: Replace Section with a VStack ---
                                // A simple VStack gives us direct control over spacing.
                                VStack(alignment: .leading, spacing: 15) { // Use spacing here to control the gap
                                    // This is our year title
                                    Text(yearDate, formatter: yearFormatter)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(Calendar.current.isDate(yearDate, equalTo: Date(), toGranularity: .year) ? .red : .primary)
                                    
                                    // This is the grid of months
                                    LazyVGrid(columns: columns, spacing: 20) {
                                        ForEach(0..<12) { monthOffset in
                                            if let monthDate = Calendar.current.date(byAdding: .month, value: monthOffset, to: yearDate) {
                                                MiniMonthView(monthDate: monthDate) {
                                                    onMonthTapped(monthDate)
                                                }
                                            }
                                        }
                                    }
                                }
                                .id(yearDate) // The ID is now on the VStack
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20) // Add a single top padding for the whole content block
                    }
                }
            }
            .onAppear {
                if years.isEmpty {
                    self.years = generateYears(for: self.year)
                }
            }
            .onChange(of: years) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    let calendar = Calendar.current
                    let targetYearComponent = calendar.dateComponents([.year], from: self.year)
                    guard let targetDate = calendar.date(from: targetYearComponent) else { return }
                    
                    proxy.scrollTo(targetDate, anchor: .top)
                }
            }
        }
    }
    
    private func generateYears(for centralYear: Date) -> [Date] {
        let calendar = Calendar.current
        var result: [Date] = []
        let component = calendar.dateComponents([.year], from: centralYear)
        guard let firstDayOfYear = calendar.date(from: component) else { return [] }

        for i in -10...10 {
            if let newYear = calendar.date(byAdding: .year, value: i, to: firstDayOfYear) {
                result.append(newYear)
            }
        }
        return result
    }
}
