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
                       let uiImage = UIImage(data: imageData) {
                        
                        // --- THE FIX: Call our new helper function ---
                        // The body is now clean. We get the cropRect from the logic function.
                        let cropRect = calculateCropRect(for: dayEntry, image: uiImage)
                        
                        // The rest of the rendering logic is now simple and clear.
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
    
    // --- THE FIX: All the complex logic is now in its own function ---
    private func calculateCropRect(for dayEntry: DayEntry?, image: UIImage) -> CGRect {
        // First, try to use a saved crop rectangle if it exists.
        if let data = dayEntry?.cropRectData, let decodedRect = try? JSONDecoder().decode(CGRect.self, from: data) {
            return decodedRect
        }
        
        // If no saved crop exists, calculate a default "center crop".
        let imageAspectRatio = image.size.width / image.size.height
        let viewAspectRatio = AppConstants.calendarCellAspectRatio
        
        var width: CGFloat = 1.0
        var height: CGFloat = 1.0
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        if imageAspectRatio > viewAspectRatio {
            // Image is wider than the view; we need to crop the sides.
            height = 1.0
            width = viewAspectRatio / imageAspectRatio
            x = (1.0 - width) / 2
        } else {
            // Image is taller than the view; we need to crop the top and bottom.
            width = 1.0
            height = imageAspectRatio / viewAspectRatio
            y = (1.0 - height) / 2
        }
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}
