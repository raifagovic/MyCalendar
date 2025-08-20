//
//  YearView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 5. 8. 2025..
//

import SwiftUI

struct YearView: View {
    // The target year we need to scroll to.
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
                        VStack(spacing: 30) {
                            ForEach(years) { yearDate in
                                Section(header:
                                    HStack {
                                        Text(yearDate, formatter: yearFormatter)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .padding(.top) // Keep inner padding for text spacing
                                            .foregroundColor(Calendar.current.isDate(yearDate, equalTo: Date(), toGranularity: .year) ? .red : .primary)
                                        Spacer()
                                    }
                                )
                                {
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
                                .id(yearDate)
                                // --- THE DEFINITIVE GEOMETRIC FIX ---
                                // We apply padding ONLY to the target year, ON THE SECTION ITSELF.
                                .padding(.top, isTargetYear(yearDate) ? 88 : 0)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            // The robust timing logic remains the same.
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
                    
                    // The .top anchor now works because we are scrolling a padded view.
                    proxy.scrollTo(targetDate, anchor: .top)
                }
            }
        }
    }
    
    // This helper function checks if the year being drawn is our target year.
    private func isTargetYear(_ yearDate: Date) -> Bool {
        return Calendar.current.isDate(yearDate, equalTo: self.year, toGranularity: .year)
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
