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
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate)
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
    
    private var weekdaySymbols: [String] {
        // This uses the user's current calendar (e.g., Sunday or Monday first)
        let formatter = DateFormatter()
        // "M", "T", "W", etc.
        return formatter.veryShortWeekdaySymbols
    }

    var body: some View {
        VStack(spacing: 0) { // Use spacing: 0 to connect the header and the grid
            
            // --- THIS IS OUR NEW CUSTOM "APPLE STYLE" HEADER ---
            VStack {
                // Month Title and Navigation Buttons
                HStack {
                    Text(currentDate, formatter: DateFormatter.monthAndYear)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                    .font(.title2)
                    
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                    .font(.title2)
                }
                .padding(.horizontal)
                .padding(.top, 10) // Add some space from the top edge

                // Weekday Symbols (M, T, W, T, F, S, S)
                HStack {
                    ForEach(weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            // This makes each symbol take up equal space
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 8)
            }
            .background(.regularMaterial) // This applies the essential blur effect!

            // --- The Main Calendar Grid in a ScrollView ---
            ScrollView {
                // The LazyVGrid for the actual days
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 12) {
                    ForEach(days.indices, id: \.self) { index in
                        let day = days[index]
                        
                        if day == Date.distantPast {
                            Rectangle().fill(Color.clear)
                        } else {
                            let entryForDay = dayEntries.first { Calendar.current.isDate($0.date, inSameDayAs: day) }
                            
                            DayCellView(day: day, dayEntry: entryForDay)
                                .onTapGesture {
                                    self.selectedDate = day
                                }
                        }
                    }
                }
                .padding(.top, 5) // A little space between the header and the grid
            }
        }
        .sheet(item: $selectedDate) { date in
            DayDetailView(date: date)
        }
        // We remove .navigationStack because we are building our own header.
        // The .sheet modifier is now attached to the main VStack.
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
