//
//  CalendarView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 4. 7. 2025..
//

import SwiftUI

struct CalendarView: View {
    @State private var currentDate = Date()

    private var days: [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        
        return range.compactMap {
            calendar.date(byAdding: .day, value: $0 - 1, to: startOfMonth)
        }
    }

    var body: some View {
        VStack {
            Text(currentDate, formatter: DateFormatter.monthAndYear)
                .font(.title)
                .padding()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) {
                    Text($0).font(.caption).bold()
                }

                ForEach(days, id: \.self) { day in
                    Text("\(Calendar.current.component(.day, from: day))")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .background(Calendar.current.isDateInToday(day) ? Color.blue.opacity(0.2) : Color.clear)
                        .clipShape(Circle())
                        .onTapGesture {
                            // Show day details
                        }
                }
            }
        }
    }
}

extension DateFormatter {
    static var monthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}
