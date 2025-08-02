//
//  StickyHeaderView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 31. 7. 2025..
//

import SwiftUI

struct StickyHeaderView: View {
    // We will pass the currently visible month's date to this view
    let currentVisibleMonth: Date
    let onTodayTapped: () -> Void // A closure for the "Today" button action
    
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
        formatter.dateFormat = "MMMM" // Full month name, e.g., "July"
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // --- FIX #1: Pushing the "Nav Bar" down ---
            // We add a simple spacer with a fixed height at the top. This pushes
            // the content down from the safe area to a standard position.
            Spacer().frame(height: 10)
            
            HStack {
                Button(action: { print("Year navigation tapped") }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text(currentVisibleMonth, formatter: yearFormatter)
                    }
                }
                .font(.title3).fontWeight(.semibold)
                
                Spacer()
                Text("Calendar").font(.headline).fontWeight(.semibold)
                Spacer()
                Button("Today", action: onTodayTapped).font(.headline)
            }
            .padding(.horizontal)
            
            // --- Month Name Row ---
            HStack {
                Text(currentVisibleMonth, formatter: monthFormatter)
                    .font(.largeTitle).fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // --- FIX #2 & #3: Correcting Weekday Letter Position ---
            // This Spacer takes up ALL available space, pushing the weekday
            // letters all the way to the bottom of the header frame.
            Spacer()
            
            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.subheadline).fontWeight(.medium).foregroundColor(.secondary).frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 8) // Small padding so it hugs the bottom
            
        }
        .frame(height: 180) // A fixed, taller height for the entire header
        .background(.regularMaterial)
        .overlay(
            // The bottom divider line, now correctly placed
            Divider().background(Color.gray.opacity(0.5)),
            alignment: .bottom
        )
    }
}
