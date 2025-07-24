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
        ZStack {
            // Layer 1: Background Image
            if let imageData = dayEntry?.backgroundImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            
            // Layer 2: Drawing
            if dayEntry?.drawingData != nil {
                // You would need a way to render the saved drawing here.
                // For simplicity, we'll show a placeholder. A full implementation
                // would convert PKDrawing data back to an image.
                Image(systemName: "pencil.tip")
                    .foregroundColor(.gray.opacity(0.5))
            }
            
            // Layer 3: Day Number and Emoticons
            VStack {
                Text("\(Calendar.current.component(.day, from: day))")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(4)
                
                Spacer()
                
                // Display Emoticons
                if let emoticons = dayEntry?.emoticons, !emoticons.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(emoticons.prefix(3)) { emoticon in // Show a max of 3 previews
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
        }
        .border(Color.red)
        .frame(minHeight: 80) // Give cells a minimum height
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .clipped()
        // The .popover modifier for showing the time "cloud"
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
