//
//  YearHeaderView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 5. 8. 2025..
//

import SwiftUI

struct YearHeaderView: View {
    // --- CHANGE 1: Remove the 'year' property ---
    // let year: Date
    let onTodayTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 10)
            
            HStack {
                // We keep the hidden button as a spacer for alignment
                Button("          ", action: {})
                    .font(.headline)
                    .hidden()
                
                Spacer()
                
                // --- CHANGE 2: Replace the year with a static title ---
                Text("Calendar")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Today", action: onTodayTapped)
                    .font(.headline)
            }
            .padding(.horizontal)
            .frame(height: 44)
        }
        // --- CHANGE 3: Add top padding to respect the safe area ---
        // This pushes the content down from the notch/status bar.
        .padding(.top)
        .background(.regularMaterial)
        .overlay(
            Divider().background(Color.gray.opacity(0.5)),
            alignment: .bottom
        )
    }
}
