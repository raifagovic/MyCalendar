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
            
            // This "Nav Bar" part will now stay anchored at the top.
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
            
            // The month name will also stay near the top.
            HStack {
                Text(currentVisibleMonth, formatter: monthFormatter)
                    .font(.largeTitle).fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // --- THE CRUCIAL FIX ---
            // Replace the fixed-height spacer with a flexible one.
            // This spacer will now expand and shrink, absorbing all height changes.
            Spacer(minLength: 0) // <-- This is the corrected line.
            
            // This Weekday Symbols row will now be pushed to the bottom of the frame.
            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.subheadline).fontWeight(.medium).foregroundColor(.secondary).frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 8)
        }
        .padding(.top)
        // Now, when you change this frame height, only the flexible Spacer will change.
        .frame(height: 150) // Try 150, 180, 200 - it will behave as you expect!
        .background(.regularMaterial)
        .overlay(
            Divider().background(Color.gray.opacity(0.5)),
            alignment: .bottom
        )
    }
}
