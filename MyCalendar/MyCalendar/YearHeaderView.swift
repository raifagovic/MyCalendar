//
//  YearHeaderView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 5. 8. 2025..
//

import SwiftUI

struct YearHeaderView: View {
    let onTodayTapped: () -> Void
    
    var body: some View {
        // --- THIS ENTIRE VStack IS COPIED FROM STICKYHEADERVIEW FOR CONSISTENCY ---
        VStack(spacing: 0) {
            
            // This spacer pushes the content down from the status bar, exactly like in the other header.
            Spacer().frame(height: 40)
            
            // This HStack is the "Nav Bar" content row.
            HStack {
                // To keep the "Calendar" title perfectly centered, we create a
                // placeholder button on the left that takes up the same space as the
                // real year button, but we make it invisible.
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                        
                        // We use a sample year text to get the width right.
                        Text("2025")
                            .font(.headline.weight(.semibold))
                    }
                }
                .disabled(true) // Disable the button
                .hidden()       // Make it completely invisible
                
                Spacer()
                
                Text("Calendar")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Today", action: onTodayTapped)
                    .font(.headline)
            }
            .padding(.horizontal)
            // Giving it a fixed height ensures perfect vertical alignment.
            .frame(height: 44)
        }
        // These modifiers are essential to match the other header.
        .padding(.top)
        .background(.regularMaterial)
        .overlay(
            Divider().background(Color.gray.opacity(0.5)),
            alignment: .bottom
        )
    }
}
