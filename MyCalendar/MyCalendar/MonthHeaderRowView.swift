
//
//  MonthHeaderRowView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 4. 8. 2025..
//

import SwiftUI

struct MonthHeaderRowView: View {
    let firstWeek: [CalendarDay]
    let firstDayOfCurrentMonth: CalendarDay?
    let monthAbbreviation: String
    
    var body: some View {
        ZStack {
            // Layer 1: The partial divider line
            HStack(spacing: 0) {
                ForEach(firstWeek) { day in
                    Rectangle()
                        .fill(day.date != .distantPast ? Color.gray.opacity(0.5) : Color.clear)
                        .frame(height: 1)
                }
            }
            
            // Layer 2: The Month Abbreviation Text
            HStack(spacing: 0) {
                ForEach(firstWeek) { day in
                    if day.id == firstDayOfCurrentMonth?.id {
                        Text(monthAbbreviation)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .textCase(.uppercase)
                            .padding(.bottom, 2)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Color.clear
                    }
                }
            }
        }
    }
}
