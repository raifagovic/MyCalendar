//
//  WeekRowView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 4. 8. 2025..
//

import SwiftUI
import SwiftData

// --- This view is now very "dumb" and only displays cells, which is perfect. ---
struct WeekRowView: View {
    let week: [CalendarDay]
    let dayEntries: [DayEntry]
    @Binding var selectedDate: Date?
    
    var body: some View {
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
