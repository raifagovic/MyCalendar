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
    
    @State private var selectedSticker: StickerInfo?
    
    private let editorWidth: CGFloat = 300.0
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let w = geometry.size.width
                let h = geometry.size.height
                
                let editorHeight = editorWidth / AppConstants.calendarCellAspectRatio
                let scaleX = w / editorWidth
                let scaleY = h / editorHeight
                
                ZStack {
                    // Background
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
                    
                    // Stickers below drawings
                    if let stickers = dayEntry?.stickers {
                        // Calculate a content scale factor based on the DayCellView's actual width
                        // relative to the editor's reference width.
                        // This ensures all sticker elements shrink proportionally from the editor's view.
                        let contentScaleFactor = w / AppConstants.editorPreviewWidth
                        
                        ForEach(stickers) { sticker in
                            let editorBaseFontSize: CGFloat = (sticker.type == .emoji) ? 24 : 12
                            let finalFontSize = editorBaseFontSize * sticker.scale * contentScaleFactor
                            
                            Text(sticker.content.isEmpty ? " " : sticker.content)
                                .font(.system(size: finalFontSize))
                                // Crucial: Prevent text wrapping. Treat the text as a single,
                                // horizontally rigid block that will be scaled and positioned.
                                .fixedSize(horizontal: true, vertical: false)
                                // Optionally, if you're certain it should always be a single line
                                // and want to truncate if it somehow still overruns (though fixedSize prevents most of this)
                                .lineLimit(1)
                                .rotationEffect(.degrees(sticker.rotationDegrees))
                                // The position is relative to the DayCellView's frame
                                .position(
                                    x: sticker.posX * w,
                                    y: sticker.posY * h
                                )
                        }
                    }
                    
                    // Drawings above stickers
                    if let data = dayEntry?.drawingData,
                       let drawing = try? PKDrawing(data: data) {
                        Canvas { context, canvasSize in
                            // The PKDrawing was created in the editor's coordinate space.
                            // We need to render it into the current cell's `canvasSize`.
                            let drawingSourceRect = CGRect(x: 0, y: 0, width: AppConstants.editorPreviewWidth, height: AppConstants.editorPreviewHeight)
                            let image = drawing.image(from: drawingSourceRect, scale: 1)
                            
                            // Now draw this image into the cell's Canvas, scaled to fit
                            context.draw(Image(uiImage: image), in: CGRect(origin: .zero, size: canvasSize))
                        }
                        .frame(width: w, height: h)
                        .clipped()
                        .allowsHitTesting(false)
                    }
                }
            }
            .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit)
            
            // Day number overlay
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
        .contentShape(Rectangle())
    }
}




