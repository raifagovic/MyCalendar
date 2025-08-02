//
//  MonthHeaderView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 31. 7. 2025..
//

import SwiftUI

struct MonthHeaderView: View {
    let monthDate: Date
    
    // A new formatter for the three-letter abbreviation
    private var threeLetterMonthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM" // "JUL", "AUG", etc.
        return formatter
    }
    
    var body: some View {
        HStack {
            Text(monthDate, formatter: threeLetterMonthFormatter)
                .font(.title2)
                .fontWeight(.bold)
                .textCase(.uppercase) // Makes it "JUL" instead of "Jul"
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }
}
