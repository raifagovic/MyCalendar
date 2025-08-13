
//
//  YearHeaderView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 5. 8. 2025..
//

import SwiftUI

struct YearHeaderView: View {
    // The year to display
    let year: Date
    // The action to perform when the user taps "Today"
    let onTodayTapped: () -> Void
    
    private var yearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 10)
            
            HStack {
                // We use a clear button on the left as a spacer
                // to perfectly balance the "Today" button on the right.
                Button("          ", action: {})
                    .font(.headline)
                    .hidden()
                
                Spacer()
                
                Text(year, formatter: yearFormatter)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Today", action: onTodayTapped)
                    .font(.headline)
            }
            .padding(.horizontal)
            .frame(height: 44)
        }
        .background(.regularMaterial)
        .overlay(
            Divider().background(Color.gray.opacity(0.5)),
            alignment: .bottom
        )
    }
}
