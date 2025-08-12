
//
//  YearView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 5. 8. 2025..
//

import SwiftUI

struct YearView: View {
    // The year we want to display (passed from CalendarView)
    let year: Date
    // A closure to execute when the user taps on a month
    let onMonthTapped: (Date) -> Void

    // A 3-column grid layout
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // A computed property to generate the 12 months of the given year
    private var months: [Date] {
        let calendar = Calendar.current
        var result: [Date] = []
        // Get the first day of the year
        guard let yearInterval = calendar.dateInterval(of: .year, for: year) else {
            return []
        }
        
        for i in 0..<12 {
            if let month = calendar.date(byAdding: .month, value: i, to: yearInterval.start) {
                result.append(month)
            }
        }
        return result
    }
    
    private var monthAbbreviationFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }

    var body: some View {
        // We add our own ScrollView here in case content overflows on smaller devices.
        ScrollView {
            // A lazy grid is efficient for this kind of layout.
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(months) { month in
                    Button(action: {
                        // When tapped, call the closure with the selected month
                        onMonthTapped(month)
                    }) {
                        Text(month, formatter: monthAbbreviationFormatter)
                            .font(.headline)
                            .foregroundColor(Calendar.current.isDate(month, equalTo: Date(), toGranularity: .month) ? .red : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
    }
}
