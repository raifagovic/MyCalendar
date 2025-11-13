//
//  YearView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 5. 8. 2025..
//

import SwiftUI
import Foundation

struct YearView: View {
    let year: Date
    let onMonthTapped: (Date) -> Void
    let onTodayTapped: () -> Void
    
    @State private var years: [Date] = []
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    private var yearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section(header: YearHeaderView(currentYear: year, onTodayTapped: {
                        let calendar = Calendar.current
                        let currentYearDate = calendar.date(from: calendar.dateComponents([.year], from: Date()))!
                        withAnimation {
                            proxy.scrollTo(currentYearDate, anchor: .top)
                        }
                    })) {
                        VStack(spacing: 0) {
                            ForEach(years, id: \.self) { yearDate in // ✅ Uses the @State `years`
                                VStack(alignment: .leading, spacing: 15) {
                                    Text(yearDate, formatter: yearFormatter)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(Calendar.current.isDate(yearDate, equalTo: Date(), toGranularity: .year) ? .red : .primary)
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.5))
                                    
                                    LazyVGrid(columns: columns, spacing: 20) {
                                        ForEach(0..<12) { monthOffset in
                                            if let monthDate = Calendar.current.date(byAdding: .month, value: monthOffset, to: yearDate) {
                                                MiniMonthView(monthDate: monthDate, onTapped: {
                                                    onMonthTapped(monthDate)
                                                })
                                            }
                                        }
                                    }
                                }
                                .id(yearDate)
                                // --- THE DEFINITIVE GEOMETRIC FIX ---
                                // We manually control all top padding here.
                                // The target year gets a large padding to clear the header.
                                // All other years get a standard, smaller padding.
                                .padding(.top, isTargetYear(yearDate) ? 110 : 30)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .task {
                // ✅ NEW: Populate the `years` array only once when the view appears.
                if years.isEmpty {
                    let calendar = Calendar.current
                    var result: [Date] = []
                    let today = Date()

                    for i in -10...10 {
                        if let yearDate = calendar.date(byAdding: .year, value: i, to: today) {
                            if let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: yearDate)) {
                                result.append(startOfYear)
                            }
                        }
                    }
                    years = result
                }
                
                await Task.yield()
                
                let calendar = Calendar.current
                let targetYearComponent = calendar.dateComponents([.year], from: self.year)
                guard let targetDate = calendar.date(from: targetYearComponent) else { return }
                
                // The .top anchor now works because we are scrolling a padded view.
                proxy.scrollTo(targetDate, anchor: .top)
            }
        }
    }
    
    // This helper function checks if the year being drawn is our target year.
    private func isTargetYear(_ yearDate: Date) -> Bool {
        return Calendar.current.isDate(yearDate, equalTo: self.year, toGranularity: .year)
    }
}
