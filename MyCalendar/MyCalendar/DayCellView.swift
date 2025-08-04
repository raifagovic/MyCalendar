
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
    
    // --- CHANGE 1: Remove properties that are no longer needed ---
    // let isFirstDayOfMonth: Bool
    // let monthAbbreviation: String
    
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
                // --- CHANGE 2: Simplified VStack. No more conditional logic for the month. ---
                VStack {
                    Text("\(Calendar.current.component(.day, from: day))")
                        .font(.headline)
                        .padding(.top, 4)
                        .frame(maxWidth: .infinity, alignment: .center) // Center the day number
                        .foregroundColor(Calendar.current.isDateInToday(day) ? .red : .white)
                    
                    Spacer() // Pushes content to top and bottom

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
