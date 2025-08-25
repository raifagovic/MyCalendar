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
    
    @State private var selectedEmoticon: EmoticonInfo?

    // --- We define the editor's width as a constant to use in our calculation ---
    private let editorWidth: CGFloat = 300.0

    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit)
            .background(
                // We use a GeometryReader to find our own size.
                GeometryReader { geometry in
                    if let imageData = dayEntry?.backgroundImageData, let uiImage = UIImage(data: imageData) {
                        
                        // --- THE PROPORTIONAL OFFSET CALCULATION ---
                        // 1. Calculate the ratio between our cell's width and the editor's width.
                        let ratio = geometry.size.width / editorWidth
                        
                        // 2. Scale the saved offset values by this ratio.
                        let scaledOffsetX = (dayEntry?.backgroundImageOffsetX ?? 0.0) * ratio
                        let scaledOffsetY = (dayEntry?.backgroundImageOffsetY ?? 0.0) * ratio
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            // 3. Remove the old .scaledToFill() as it conflicts with our manual transform.
                            .scaledToFill() // <-- This line might need to be `.scaledToFill()` on the container instead
                            // 4. Apply the UNCHANGED scale and the NEWLY-CALCULATED offset.
                            .scaleEffect(dayEntry?.backgroundImageScale ?? 1.0)
                            .offset(x: scaledOffsetX, y: scaledOffsetY)
                            // This ensures the image is centered in the frame before offset is applied
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            )
            .overlay(
                // ... The overlay for the day number is unchanged ...
                VStack {
                    Text("\(Calendar.current.component(.day, from: day))")
                        .font(.headline)
                        .padding(.top, 4)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(Calendar.current.isDateInToday(day) ? .red : .white)
                    
                    Spacer()

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
            // ... The rest of the modifiers are unchanged ...
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
