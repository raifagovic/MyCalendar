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
    let onYearTapped: () -> Void
    
    private static let cachedWeekdaySymbols: [String] = {
        let formatter = DateFormatter()
        guard let symbols = formatter.veryShortWeekdaySymbols else { return [] }
        
        let calendar = Calendar.current
        let firstWeekdayIndex = calendar.firstWeekday - 1
        let orderedSymbols = Array(symbols[firstWeekdayIndex...]) + Array(symbols[..<firstWeekdayIndex])
        return orderedSymbols
    }()
    
    private var weekdaySymbols: [String] {
        return StickyHeaderView.cachedWeekdaySymbols
    }
    
    private static let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }()
    
    private var yearFormatter: DateFormatter { StickyHeaderView.yearFormatter }
    private var monthFormatter: DateFormatter { StickyHeaderView.monthFormatter }
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer().frame(height: 40)
            
            // "Nav Bar" content row
            HStack {
                Button(action: onYearTapped) {
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
                ForEach(weekdaySymbols.indices, id: \.self) { index in
                    
                    let symbol = weekdaySymbols[index]
                    
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
