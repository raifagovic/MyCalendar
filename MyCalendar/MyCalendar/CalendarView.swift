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

    var body: some View {
        NavigationStack {
            // ScrollViewReader allows us to programmatically jump to a specific month
            ScrollViewReader { proxy in
                ScrollView {
                    // LazyVStack is crucial for performance. It only renders visible months.
                    LazyVStack(spacing: 0) {
                        ForEach(months, id: \.self) { month in
                            MonthView(monthDate: month, dayEntries: dayEntries, selectedDate: $selectedDate)
                                // We give each month an ID so the ScrollViewReader can find it
                                .id(month.startOfMonth)
                        }
                    }
                }
                .navigationTitle("Calendar")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // The "Today" button uses the proxy to scroll to the current month
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Today") {
                            withAnimation {
                                proxy.scrollTo(Date().startOfMonth, anchor: .top)
                            }
                        }
                    }
                }
                .onAppear {
                    // When the view appears, generate our list of months
                    if months.isEmpty {
                        months = generateMonths()
                    }
                    // And immediately jump to the current month
                    DispatchQueue.main.async {
                        proxy.scrollTo(Date().startOfMonth, anchor: .top)
                    }
                }
            }
        }
        .sheet(item: $selectedDate) { date in
            DayDetailView(date: date)
        }
    }
    
    // Generates a list of months, e.g., 10 years past and 10 years future
    private func generateMonths() -> [Date] {
        var result: [Date] = []
        let calendar = Calendar.current
        let today = Date()
        
        for i in -120...120 { // -10 years to +10 years
            if let month = calendar.date(byAdding: .month, value: i, to: today) {
                result.append(month.startOfMonth)
            }
        }
        return result
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
