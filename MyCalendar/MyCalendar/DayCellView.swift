//
//  DayCellView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 23. 7. 2025..
//

import SwiftUI
import PencilKit

struct DayCellView: View {
    let day: Date
    let dayEntry: DayEntry?
    var onTap: (() -> Void)? = nil
    var onLongPress: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let w = geometry.size.width
                let h = geometry.size.height
                
                // Use AppConstants for editor dimensions
                let editorWidth = AppConstants.editorPreviewWidth // ✅ Use constant
                let editorHeight = AppConstants.editorPreviewHeight // ✅ Use constant
                let scaleX = w / editorWidth
                let scaleY = h / editorHeight
                
                ZStack {
                    Group {
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
                    
                    // Stickers
                    if let stickers = dayEntry?.stickers {
                        let contentScaleFactor = w / AppConstants.editorPreviewWidth
                        
                        ForEach(stickers) { sticker in
                            // Use AppConstants for base font sizes
                            let editorBaseFontSize: CGFloat = (sticker.type == .emoji) ? AppConstants.stickerEmojiBaseFontSize : AppConstants.stickerTextBaseFontSize // ✅ Use constants
                            let finalFontSize = editorBaseFontSize * sticker.scale * contentScaleFactor
                            
                            Text(sticker.content.isEmpty ? " " : sticker.content)
                                .font(.system(size: finalFontSize))
                                .fixedSize(horizontal: true, vertical: false)
                                .lineLimit(1)
                                .rotationEffect(.degrees(sticker.rotationDegrees))
                                .position(
                                    x: sticker.posX * w,
                                    y: sticker.posY * h
                                )
                        }
                    }
                    
                    // Drawings
                    if let data = dayEntry?.drawingData,
                       let drawing = try? PKDrawing(data: data) {
                        Canvas { context, canvasSize in
                            let drawingSourceRect = CGRect(
                                x: 0,
                                y: 0,
                                width: AppConstants.editorPreviewWidth,
                                height: AppConstants.editorPreviewHeight
                            )
                            let image = drawing.image(from: drawingSourceRect, scale: 1)
                            context.draw(Image(uiImage: image), in: CGRect(origin: .zero, size: canvasSize))
                        }
                        .frame(width: w, height: h)
                        .clipped()
                        .allowsHitTesting(false)
                    }
                }
            }
            // Use AppConstants for aspect ratio
            .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit) // ✅ Use constant
            
            // Day number overlay
            VStack {
                Text("\(day.day)")
                    .font(.headline)
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(day.isSameDay(as: Date()) ? .red : .white)
                Spacer()
            }
            .padding(4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            onLongPress?()
        }
    }
}
