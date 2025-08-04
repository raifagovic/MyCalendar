//
//  DayCellView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 23. 7. 2025..
//

import SwiftUI

struct DayCellView: View {
    let day: Date
    let dayEntry: DayEntry?
    
    // --- CHANGE 1: Add new properties ---
    let isFirstDayOfMonth: Bool
    let monthAbbreviation: String
    
    @State private var selectedEmoticon: EmoticonInfo?

    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit)
            .background(
                Group {
                    if let imageData = dayEntry?.backgroundImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(dayEntry?.backgroundImageScale ?? 1.0)
                            .offset(
                                x: dayEntry?.backgroundImageOffsetX ?? 0.0,
                                y: dayEntry?.backgroundImageOffsetY ?? 0.0
                            )
                    }
                }
            )
            .overlay(
                // --- CHANGE 2: The main content VStack ---
                VStack(spacing: 2) { // Add a little spacing
                    
                    // --- CHANGE 3: Conditionally display the month abbreviation ---
                    if isFirstDayOfMonth {
                        Text(monthAbbreviation)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red) // Make it stand out
                            .textCase(.uppercase)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        // If it's not the first day, we add a clear rectangle
                        // to ensure the day number aligns vertically with other weeks.
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 14) // Approximate height of the text
                    }
                    
                    Text("\(Calendar.current.component(.day, from: day))")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center) // Center the day number
                        .foregroundColor(Calendar.current.isDateInToday(day) ? .red : .white)
                    
                    Spacer(minLength: 0)

                    if let emoticons = dayEntry?.emoticons, !emoticons.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(emoticons.prefix(3)) { emoticon in
                                Text(emoticon.character)
                                    .font(.caption)
                                    .onTapGesture {
                                        self.selectedEmoticon = emoticon
                                    }
                            }
                        }
                        .padding(.bottom, 4)
                    }
                }
                .padding(.top, 4) // Add padding to the top of the VStack
            )
            .cornerRadius(8)
            .clipped()
            .popover(item: $selectedEmoticon) { emoticon in
                VStack {
                    if let time = emoticon.time {
                        Text("Time: \(time, formatter: timeFormatter)")
                    } else {
                        Text("No time set")
                    }
                }
                .padding()
            }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}
