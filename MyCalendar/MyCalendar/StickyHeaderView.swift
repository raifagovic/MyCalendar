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
            
            // This section for the "Nav Bar" is already good.
            // It simulates the standard height correctly.
            VStack {
                Spacer()
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
            }
            .frame(height: 44)
            
            // --- Month Name Row ---
            HStack {
                Text(currentVisibleMonth, formatter: monthFormatter)
                    .font(.largeTitle).fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // --- FIX #1: REMOVE THE LARGE GAP ---
            // We remove the flexible Spacer() that was creating the huge
            // gap between the month name and the weekday letters.
            // Spacer() // <-- DELETE THIS LINE
            
            // We use a small, fixed-height spacer instead to control the gap precisely.
            Spacer().frame(height: 15)
            
            
            // --- Weekday Symbols Row ---
            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.subheadline).fontWeight(.medium).foregroundColor(.secondary).frame(maxWidth: .infinity)
                }
            }
            // --- FIX #2: ALIGN LETTERS WITH MONTH NAME ---
            // We add horizontal padding to ensure the letters align perfectly
            // with the month name text above it.
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.top)
        // --- FIX #3: INCREASE HEADER DEPTH ---
        // We increase the fixed height of the entire header to give it the
        // "deeper" feel you wanted.
        .frame(height: 180) // Increased from 160 to 180
        .background(.regularMaterial)
        .overlay(
            Divider().background(Color.gray.opacity(0.5)),
            alignment: .bottom
        )
    }
}
