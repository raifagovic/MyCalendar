//
//  WeekRowView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 4. 8. 2025..
//

import SwiftUI
import SwiftData

struct WeekRowView: View {
    // --- CHANGE 1: It needs more information now ---
    let week: [CalendarDay]
    let dayEntries: [DayEntry]
    @Binding var selectedDate: Date?
    
    // These properties will help it decide what to draw
    let monthDate: Date
    let isFirstContentWeek: Bool
    let firstDayOfCurrentMonth: CalendarDay?
    
    // --- ADD THIS HELPER ---
    private var isCurrentMonth: Bool {
        Calendar.current.isDate(monthDate, equalTo: Date(), toGranularity: .month)
    }
    
    // This helper needs to be here now
    private var monthAbbreviationFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }
    
    var body: some View {
        // The root view is a VStack that contains the divider AND the day cells
        VStack(spacing: 0) {
            
            // --- CHANGE 2: ALL THE COMPLEX LOGIC MOVED HERE ---
            
            // Case 1: Is this the very first week with content?
            if isFirstContentWeek {
                // If so, draw the special header with the line and the text.
                ZStack {
                    // The divider line
                    HStack(spacing: 0) {
                        ForEach(week) { day in
                            Rectangle()
                                .fill(day.date != .distantPast ? Color.gray.opacity(0.5) : Color.clear)
                                .frame(height: 1)
                        }
                    }
                    // The month text, aligned perfectly
                    HStack(spacing: 0) {
                        ForEach(week) { day in
                            if day.date != .distantPast && Calendar.current.component(.day, from: day.date) == 1 {
                                Text(monthAbbreviationFormatter.string(from: monthDate))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Calendar.current.isDate(monthDate, equalTo: Date(), toGranularity: .month) ? .red : .primary)
                                    .offset(y: -22)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                Color.clear
                            }
                        }
                    }
                }
            }
            // Case 2: Is this a *later* week that has content?
            else if week.contains(where: { $0.date != .distantPast }) {
                // If so, draw a simple divider line.
                HStack(spacing: 0) {
                    ForEach(week) { day in
                        Rectangle()
                            .fill(day.date != .distantPast ? Color.gray.opacity(0.5) : Color.clear)
                            .frame(height: 1)
                    }
                }
            }
            
            // --- CHANGE 3: The simple row of cells is the last thing drawn ---
            HStack(spacing: 0) {
                ForEach(week) { day in
                    if day.date == Date.distantPast {
                        Rectangle().fill(Color.clear)
                    } else {
                        DayCellView(
                            day: day.date,
                            dayEntry: dayEntries.first { Calendar.current.isDate($0.date, inSameDayAs: day.date) }
                        )
                        .onTapGesture {
                            self.selectedDate = day.date
                        }
                    }
                }
            }
        }
    }
}
