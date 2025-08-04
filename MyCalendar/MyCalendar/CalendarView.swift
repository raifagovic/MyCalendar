//
//  CalendarView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 4. 7. 2025..
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query(sort: \DayEntry.date) private var dayEntries: [DayEntry]
    
    @State private var months: [Date] = []
    @State private var selectedDate: Date?
    
    // NEW: This state variable will track the top-most visible month
    @State private var currentVisibleMonth: Date = Date()

    var body: some View {
        ScrollViewReader { proxy in
            // The ScrollView is now the root view.
            ScrollView {
                // LazyVStack contains our scrolling months
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    
                    // We now define our header as a "Section" inside the LazyVStack.
                    // The .pinnedViews modifier makes it stick to the top.
                    Section(header: StickyHeaderView(
                        currentVisibleMonth: currentVisibleMonth,
                        onTodayTapped: {
                            withAnimation {
                                proxy.scrollTo(Date().startOfMonth, anchor: .top)
                            }
                        }
                    )) {
                        // This is the content of the section, i.e., all the months.
                        ForEach(months, id: \.self) { month in
                            MonthView(monthDate: month, dayEntries: dayEntries, selectedDate: $selectedDate)
                                .id(month.startOfMonth)
                                .onAppear { // <-- REMOVE THIS MODIFIER
                                            // This tracks which month is at the top of the list.
                                            // We can use this to update the header's month name.
                                            self.currentVisibleMonth = month
                                        }
                        }
                    }
                }
            }
            // This modifier makes the content go under the status bar, BUT tells
            // SwiftUI to arrange the layout respecting the safe area.
            .ignoresSafeArea(edges: .top)
            .background(Color.black)
            .onAppear {
                if months.isEmpty {
                    months = generateMonths()
                }
                // Immediately jump to the current month on launch.
                DispatchQueue.main.async {
                    proxy.scrollTo(Date().startOfMonth, anchor: .top)
                }
            }
        }
        .sheet(item: $selectedDate) { date in
            DayDetailView(date: date)
        }
    }

    private func generateMonths() -> [Date] {
        var result: [Date] = []
        let calendar = Calendar.current
        let today = Date()
        
        // Generate a range of months, for example:
        // 120 months into the past (10 years)
        // 120 months into the future (10 years)
        let monthRange = -120...120
        
        for i in monthRange {
            if let month = calendar.date(byAdding: .month, value: i, to: today) {
                // We use startOfMonth to ensure each date represents the beginning of a unique month
                result.append(month.startOfMonth)
            }
        }
        // The list of months might not be sorted if generated this way, so we sort it.
        return result.sorted()
    }
}

// Helper extensions to make working with dates easier
extension Date {
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
}

// Keep these extensions
extension Date: Identifiable {
    public var id: Date { self }
}

extension DateFormatter {
    static var monthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}
