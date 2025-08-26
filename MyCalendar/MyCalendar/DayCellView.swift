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

    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit)
            .background(
                GeometryReader { geometry in
                    if let imageData = dayEntry?.backgroundImageData,
                       let uiImage = UIImage(data: imageData),
                       let data = dayEntry?.cropRectData,
                       let cropRect = try? JSONDecoder().decode(CGRect.self, from: data) {
                        
                        // --- THE NEW RENDERING LOGIC ---
                        let imageSize = uiImage.size
                        let scale = geometry.size.width / (cropRect.width * imageSize.width)
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(scale)
                            .offset(
                                x: (-cropRect.midX * imageSize.width) * scale + (geometry.size.width / 2),
                                y: (-cropRect.midY * imageSize.height) * scale + (geometry.size.height / 2)
                            )
                            // This ensures the frame is constrained before clipping
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
            .cornerRadius(8)
            // --- THE SPILLOVER FIX ---
            // This is the most important modifier. It ensures nothing can
            // be drawn or tapped outside the cell's rounded rectangle frame.
            .clipped()
            .popover(item: $selectedEmoticon) { emoticon in
                // ... popover content is unchanged ...
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
