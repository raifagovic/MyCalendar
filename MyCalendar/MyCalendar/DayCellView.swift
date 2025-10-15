//
//  DayCellView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 23. 7. 2025..
//

//import SwiftUI
//import PencilKit
//
//struct DayCellView: View {
//    let day: Date
//    let dayEntry: DayEntry?
//    var onTap: (() -> Void)? = nil // 👈 callback for short tap
//    
//    @State private var showingNotificationsSheet = false // 👈 for long-press popup
//    
//    private let editorWidth: CGFloat = 300.0
//    
//    var body: some View {
//        ZStack {
//            GeometryReader { geometry in
//                let w = geometry.size.width
//                let h = geometry.size.height
//                
//                let editorHeight = editorWidth / AppConstants.calendarCellAspectRatio
//                let scaleX = w / editorWidth
//                let scaleY = h / editorHeight
//                
//                ZStack {
//                    // Background
//                    if let imageData = dayEntry?.backgroundImageData,
//                       let uiImage = UIImage(data: imageData) {
//                        
//                        let scaledOffsetX = (dayEntry?.backgroundImageOffsetX ?? 0.0) * scaleX
//                        let scaledOffsetY = (dayEntry?.backgroundImageOffsetY ?? 0.0) * scaleY
//                        
//                        Image(uiImage: uiImage)
//                            .resizable()
//                            .scaledToFill()
//                            .scaleEffect(dayEntry?.backgroundImageScale ?? 1.0)
//                            .offset(x: scaledOffsetX, y: scaledOffsetY)
//                            .frame(width: w, height: h)
//                            .clipped()
//                            .allowsHitTesting(false)
//                    } else {
//                        Color.clear
//                    }
//                    
//                    // Stickers
//                    if let stickers = dayEntry?.stickers {
//                        let contentScaleFactor = w / AppConstants.editorPreviewWidth
//                        
//                        ForEach(stickers) { sticker in
//                            let editorBaseFontSize: CGFloat = (sticker.type == .emoji) ? 24 : 12
//                            let finalFontSize = editorBaseFontSize * sticker.scale * contentScaleFactor
//                            
//                            Text(sticker.content.isEmpty ? " " : sticker.content)
//                                .font(.system(size: finalFontSize))
//                                .fixedSize(horizontal: true, vertical: false)
//                                .lineLimit(1)
//                                .rotationEffect(.degrees(sticker.rotationDegrees))
//                                .position(
//                                    x: sticker.posX * w,
//                                    y: sticker.posY * h
//                                )
//                        }
//                    }
//                    
//                    // Drawings
//                    if let data = dayEntry?.drawingData,
//                       let drawing = try? PKDrawing(data: data) {
//                        Canvas { context, canvasSize in
//                            let drawingSourceRect = CGRect(
//                                x: 0,
//                                y: 0,
//                                width: AppConstants.editorPreviewWidth,
//                                height: AppConstants.editorPreviewHeight
//                            )
//                            let image = drawing.image(from: drawingSourceRect, scale: 1)
//                            context.draw(Image(uiImage: image), in: CGRect(origin: .zero, size: canvasSize))
//                        }
//                        .frame(width: w, height: h)
//                        .clipped()
//                        .allowsHitTesting(false)
//                    }
//                }
//            }
//            .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit)
//            
//            // Day number overlay
//            VStack {
//                Text("\(Calendar.current.component(.day, from: day))")
//                    .font(.headline)
//                    .padding(.top, 4)
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .foregroundColor(Calendar.current.isDateInToday(day) ? .red : .white)
//                
//                Spacer()
//            }
//            .padding(4)
//        }
//        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
//        .contentShape(Rectangle())
//        // 👇 Gestures
//        .onTapGesture {
//            onTap?() // Short tap opens DayDetailView
//        }
//        .onLongPressGesture(minimumDuration: 0.5) {
//            // Long press opens notification view
//            showingNotificationsSheet = true
//        }
//        .sheet(isPresented: $showingNotificationsSheet) {
//            DayNotificationsView(date: day)
//        }
//    }
//}

import SwiftUI
import PencilKit

struct DayCellView: View {
    let day: Date
    let dayEntry: DayEntry?
    var onTap: (() -> Void)? = nil
    var onLongPress: (() -> Void)? = nil

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
                            .contentShape(Rectangle())
                            .allowsHitTesting(true)
                    }

                    if let stickers = dayEntry?.stickers {
                        let contentScaleFactor = w / AppConstants.editorPreviewWidth
                        ForEach(stickers) { sticker in
                            let baseFontSize: CGFloat = sticker.type == .emoji ? 24 : 12
                            let finalFontSize = baseFontSize * sticker.scale * contentScaleFactor

                            Text(sticker.content.isEmpty ? " " : sticker.content)
                                .font(.system(size: finalFontSize))
                                .fixedSize()
                                .rotationEffect(.degrees(sticker.rotationDegrees))
                                .position(x: sticker.posX * w, y: sticker.posY * h)
                        }
                    }

                    if let data = dayEntry?.drawingData,
                       let drawing = try? PKDrawing(data: data) {
                        Canvas { context, size in
                            let rect = CGRect(x: 0, y: 0,
                                              width: AppConstants.editorPreviewWidth,
                                              height: AppConstants.editorPreviewHeight)
                            let image = drawing.image(from: rect, scale: 1)
                            context.draw(Image(uiImage: image),
                                         in: CGRect(origin: .zero, size: size))
                        }
                        .frame(width: w, height: h)
                        .clipped()
                        .allowsHitTesting(false)
                    }
                }
            }
            .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit)

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
        // 👇 these modifiers must be on the OUTERMOST container
        .background(Color.black.opacity(0.001)) // ensures touch area even when empty
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())

        // ✅ Short tap gesture (works normally)
        .onTapGesture {
            print("✅ Short tap detected on \(day)")
            onTap?()
        }

        // ✅ Long press (backup recognizer)
        .onLongPressGesture(minimumDuration: 0.5) {
            print("🟡 Long press detected on \(day)")
            onLongPress?()
        }

        // ✅ Simultaneous gesture to bypass scroll interference
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    print("🧩 Simultaneous long press fired for \(day)")
                    onLongPress?()
                }
        )
    }
}
