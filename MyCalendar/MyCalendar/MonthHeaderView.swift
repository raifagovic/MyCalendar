//
//  MonthHeaderView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 31. 7. 2025..
//

import SwiftUI

struct MonthHeaderView: View {
    let monthDate: Date
    
    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        return formatter.veryShortWeekdaySymbols
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Month Title
            HStack {
                Text(monthDate, formatter: DateFormatter.monthAndYear)
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)

            // Weekday Symbols Header
            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
        }
    }
}
