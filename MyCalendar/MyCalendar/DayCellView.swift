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

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let w = geometry.size.width
                let h = geometry.size.height
                
                // editor height derived from your editorWidth + app aspect ratio
                let editorHeight = editorWidth / AppConstants.calendarCellAspectRatio
                
                // scale for X and Y separately
                let scaleX = w / editorWidth
                let scaleY = h / editorHeight

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

                // Stickers
                if let stickers = dayEntry?.stickers {
                    ForEach(stickers) { sticker in
                        Text(sticker.content)
                            .font(sticker.type == .emoji ? .caption : .footnote)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .scaleEffect(sticker.scale * ((scaleX + scaleY)/2))
                            .offset(
                                x: sticker.posX * scaleX,
                                y: sticker.posY * scaleY
                            )
                            .onTapGesture {
                                selectedSticker = sticker
                            }
                    }
                }
            }
            .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit)

            // Day number
            VStack {
                Text("\(Calendar.current.component(.day, from: day))")
                    .font(.headline)
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Calendar.current.isDateInToday(day) ? .red : .white)
                
                Spacer()
            }
            .padding(4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .contentShape(Rectangle()) // ensure tappable area
    }
}


