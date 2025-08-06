//
//  StickyHeaderView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 31. 7. 2025..
//

import SwiftUI

struct StickyHeaderView: View {
    let currentVisibleMonth: Date
    let onTodayTapped: () -> Void
    
    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        return formatter.veryShortWeekdaySymbols
    }
    
    private var yearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // --- THE FIX: ADD A SPACER AT THE VERY TOP ---
            // This spacer creates the gap between the status bar area and
            // the navigation buttons, pushing the buttons down.
            Spacer().frame(height: 10)
            
            // "Nav Bar" content row
            HStack {
                Button(action: { print("Year navigation tapped") }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                        
                        Text(currentVisibleMonth, formatter: yearFormatter)
                            .font(.headline.weight(.semibold))
                    }
                }
                
                Spacer()
                Text("Calendar").font(.headline).fontWeight(.semibold)
                Spacer()
                Button("Today", action: onTodayTapped).font(.headline)
            }
            .padding(.horizontal)
            // We give this row a consistent height for alignment.
            .frame(height: 44)

            
            // Month Name
            HStack {
                Text(currentVisibleMonth, formatter: monthFormatter)
                    .font(.largeTitle).fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // Flexible space that handles the overall header height
            Spacer(minLength: 0)
            
            // Weekday Symbols
            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 8)
        }
        .padding(.top) // This padding respects the device's safe area (notch/status bar)
        .frame(height: 150)
        .background(.regularMaterial)
        .overlay(
            Divider().background(Color.gray.opacity(0.5)),
            alignment: .bottom
        )
    }
}
