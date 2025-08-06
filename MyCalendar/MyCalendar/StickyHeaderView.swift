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
            
            // "Nav Bar"
            VStack {
                Spacer()
                HStack {
                    Button(action: { print("Year navigation tapped") }) {
                        HStack(spacing: 4) {
                            // --- CHANGE 1: Give the Image its OWN font size ---
                            // This keeps the chevron large.
                            Image(systemName: "chevron.left")
                                .font(.title3.weight(.semibold))
                            
                            // --- CHANGE 2: Give the Text its OWN, SMALLER font size ---
                            Text(currentVisibleMonth, formatter: yearFormatter)
                                .font(.headline.weight(.semibold)) // .headline is smaller than .title3
                        }
                    }
                    // --- CHANGE 3: Remove the old modifier from the HStack ---
                    // .font(.title3).fontWeight(.semibold) // <-- This line is removed
                    
                    Spacer()
                    Text("Calendar").font(.headline).fontWeight(.semibold)
                    Spacer()
                    Button("Today", action: onTodayTapped).font(.headline)
                }
                .padding(.horizontal)
            }
            .frame(height: 44)
            
            // Month Name
            HStack {
                Text(currentVisibleMonth, formatter: monthFormatter)
                    .font(.largeTitle).fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // Flexible space
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
        .padding(.top)
        .frame(height: 150)
        .background(.regularMaterial)
        .overlay(
            Divider().background(Color.gray.opacity(0.5)),
            alignment: .bottom
        )
    }
}
