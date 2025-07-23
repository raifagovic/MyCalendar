//
//  CalendarView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 4. 7. 2025..
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DayEntry.date) private var dayEntries: [DayEntry] // Fetch all saved entries
    
    @State private var currentDate = Date()
    @State private var selectedDate: Date?

    private var days: [Date] {
        // This logic is good, but needs to handle empty days for the grid layout
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else { return [] }

        var allDays: [Date] = []
        let firstDayOfWeek = calendar.component(.weekday, from: monthInterval.start)
        let emptyDays = (firstDayOfWeek - calendar.firstWeekday + 7) % 7
        
        // Add empty placeholders for days before the 1st
        for _ in 0..<emptyDays {
            allDays.append(Date.distantPast) // Use a placeholder
        }
        
        // Add the actual days of the month
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let daysInMonth = range.compactMap {
            calendar.date(byAdding: .day, value: $0 - 1, to: monthInterval.start)
        }
        allDays.append(contentsOf: daysInMonth)
        
        return allDays
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Header with month and navigation
                HStack {
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text(currentDate, formatter: DateFormatter.monthAndYear)
                        .font(.title)
                    Spacer()
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding()

                // Day of the week headers
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) {
                        Text($0).font(.caption).bold()
                    }
                }

                // The calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(days.indices, id: \.self) { index in
                        let day = days[index]
                        
                        if day == Date.distantPast { // Empty placeholder cell
                            Rectangle().fill(Color.clear)
                        } else {
                            // Find the data for this day
                            let entryForDay = dayEntries.first { Calendar.current.isDate($0.date, inSameDayAs: day) }
                            
                            DayCellView(day: day, dayEntry: entryForDay)
                                .onTapGesture {
                                    self.selectedDate = day
                                }
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
            .sheet(item: $selectedDate) { date in
                // Presenting the detail view when a date is selected
                DayDetailView(date: date)
            }
        }
    }
    
    private func changeMonth(by amount: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: amount, to: currentDate) {
            currentDate = newDate
        }
    }
}

// Add this extension to make Date identifiable for the .sheet modifier
extension Date: Identifiable {
    public var id: Date { self }
}

extension DateFormatter {
    static var monthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy" // e.g., "July 2025"
        return formatter
    }
}
