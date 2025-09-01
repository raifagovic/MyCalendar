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
    
    private let editorWidth: CGFloat = 300.0

    var body: some View {
        ZStack {
//            GeometryReader { geometry in
//                if let imageData = dayEntry?.backgroundImageData,
//                   let uiImage = UIImage(data: imageData) {
//                    
//                    let ratio = geometry.size.width / editorWidth
//                    let scaledOffsetX = (dayEntry?.backgroundImageOffsetX ?? 0.0) * ratio
//                    let scaledOffsetY = (dayEntry?.backgroundImageOffsetY ?? 0.0) * ratio
//                    
//                    Image(uiImage: uiImage)
//                        .resizable()
//                        .scaledToFill()
//                        .scaleEffect(dayEntry?.backgroundImageScale ?? 1.0)
//                        .offset(x: scaledOffsetX, y: scaledOffsetY)
//                        .frame(width: geometry.size.width, height: geometry.size.height)
//                        .clipped()                   // clip to the cell frame
//                        .allowsHitTesting(false)     // <- IMPORTANT: image won’t intercept taps
//                } else {
//                    Color.clear
//                }
//            }
            GeometryReader { geometry in
                let w = geometry.size.width
                let h = geometry.size.height

                // editor height derived from your editorWidth + app aspect ratio
                let editorHeight = editorWidth / AppConstants.calendarCellAspectRatio

                // scale for X and Y separately
                let scaleX = w / editorWidth
                let scaleY = h / editorHeight

                ZStack {
                    if let imageData = dayEntry?.backgroundImageData,
                       let uiImage = UIImage(data: imageData) {

                        let scaledOffsetX = (dayEntry?.backgroundImageOffsetX ?? 0.0) * scaleX
                        let scaledOffsetY = (dayEntry?.backgroundImageOffsetY ?? 0.0) * scaleY

                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(dayEntry?.backgroundImageScale ?? 1.0)
                            .offset(x: scaledOffsetX, y: scaledOffsetY)
                            .frame(width: w, height: h)
                            .clipped()
                            .allowsHitTesting(false)
                    } else {
                        Color.clear
                    }
                }
                // invisible background view used to run the logging side-effect safely
                .background(
                    Color.clear
                        .onAppear {
                            print("DayCell size = \(w) x \(h), ratio = \(w / h)")
                        }
                )
            }

            .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit)
            
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
            .padding(4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .contentShape(Rectangle()) // ensure the *cell* defines the tappable area
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

