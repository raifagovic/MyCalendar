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

    @State private var selectedSticker: StickerInfo?

    private let editorWidth: CGFloat = AppConstants.editorPreviewWidth
    private let editorHeight: CGFloat = AppConstants.editorPreviewHeight

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let w = geometry.size.width
                let h = geometry.size.height

                let scaleX = w / editorWidth
                let scaleY = h / editorHeight

                ZStack {
                    // Background image
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

                    // Stickers (text + emoji, positioned using relative coordinates)
                    if let stickers = dayEntry?.stickers {
                        ForEach(stickers) { sticker in
                            let posX = (sticker.relativePosX - 0.5) * w
                            let posY = (sticker.relativePosY - 0.5) * h

                            Group {
                                if sticker.type == .emoji {
                                    Text(sticker.content)
                                        .font(.system(size: 14))
                                } else {
                                    Text(sticker.content.isEmpty ? " " : sticker.content)
                                        .font(.system(size: 10))
                                        .padding(2)
                                        .background(Color.white.opacity(0.6))
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                            }
                            .scaleEffect(sticker.scale)
                            .offset(x: posX, y: posY)
                            .allowsHitTesting(false)
                        }
                    }
                }
                .frame(width: w, height: h)
            }
            .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit)

            // Overlay for day number and optional emojis
            VStack {
                Text("\(Calendar.current.component(.day, from: day))")
                    .font(.headline)
                    .padding(.top, 2)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Calendar.current.isDateInToday(day) ? .red : .white)

                Spacer()
            }
            .padding(2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .contentShape(Rectangle())
    }
}



