//
//  DayCellView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 23. 7. 2025..
//

import SwiftUI

struct DayCellView: View {
    let day: Date
    let dayEntry: DayEntry? // The data for this day, if it exists
    
    // State to manage the popover for a single emoticon
    @State private var selectedEmoticon: EmoticonInfo?

    var body: some View {
        // This is the "master" view. It's an invisible rectangle that defines the
        // shape and size of our entire cell. Everything else will conform to it.
        Rectangle()
            .fill(Color.clear) // Make the base shape transparent
//            .frame(maxWidth: .infinity) // It will take the full width of the column
//            .frame(height: 100)        // Every cell will be EXACTLY 100 points tall
            .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit)
        
            // BACKGROUND LAYER: The Image
            // The .background modifier automatically clips its content to the shape
            // of the view it's attached to (our Rectangle). This is the key.
            .background(
                Group {
                    if let imageData = dayEntry?.backgroundImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            // --- APPLY THE SAVED TRANSFORMS ---
                            .scaledToFill() // Ensures the image always covers the frame area
                            .scaleEffect(dayEntry?.backgroundImageScale ?? 1.0)
                            .offset(
                                x: dayEntry?.backgroundImageOffsetX ?? 0.0,
                                y: dayEntry?.backgroundImageOffsetY ?? 0.0
                            )
            
                    }
                }
            )

            // FOREGROUND LAYER: The day number and emoticons
            // The .overlay modifier draws this content on top of our Rectangle and its background.
            .overlay(
                VStack {
                    Text("\(Calendar.current.component(.day, from: day))")
                        .font(.headline)
                        .padding(.top, 4)
                        .frame(maxWidth: .infinity, alignment: .top) // Position top-left

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

            // FINAL MODIFIERS
            // These are applied to the entire composition.
            .background(Color.gray.opacity(0.1)) // A fallback color for empty days
            .cornerRadius(8)
            .clipped() // Ensures everything respects the rounded corners clipping
            
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
