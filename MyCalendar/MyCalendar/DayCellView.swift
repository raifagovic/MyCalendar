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
//    var onLongPress: (() -> Void)? = nil
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
//            onLongPress?() // 👈 Call callback instead of showing sheet directly
//        }
//    }
//}

import SwiftUI
import PencilKit

// MARK: - Image caches

final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private init() {}
    
    func image(forKey key: String) -> UIImage? { cache.object(forKey: key as NSString) }
    func set(_ image: UIImage, forKey key: String) { cache.setObject(image, forKey: key as NSString) }
}

// Separate cache for PKDrawing previews
final class DrawingCache {
    static let shared = DrawingCache()
    private let cache = NSCache<NSString, UIImage>()
    private init() {}
    
    func image(forKey key: String) -> UIImage? { cache.object(forKey: key as NSString) }
    func set(_ image: UIImage, forKey key: String) { cache.setObject(image, forKey: key as NSString) }
}

// MARK: - DayCellView

struct DayCellView: View {
    let day: Date
    let dayEntry: DayEntry?
    var onTap: (() -> Void)? = nil
    var onLongPress: (() -> Void)? = nil
    
    private let editorWidth: CGFloat = 300.0
    @State private var backgroundImage: UIImage? = nil
    @State private var drawingImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let w = geometry.size.width
                let h = geometry.size.height
                
                let editorHeight = editorWidth / AppConstants.calendarCellAspectRatio
                let scaleX = w / editorWidth
                let scaleY = h / editorHeight
                
                ZStack {
                    // MARK: Background
                    if let bg = backgroundImage {
                        let scaledOffsetX = (dayEntry?.backgroundImageOffsetX ?? 0.0) * scaleX
                        let scaledOffsetY = (dayEntry?.backgroundImageOffsetY ?? 0.0) * scaleY
                        
                        Image(uiImage: bg)
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
                    
                    // MARK: Stickers
                    if let stickers = dayEntry?.stickers {
                        let contentScaleFactor = w / AppConstants.editorPreviewWidth
                        
                        ForEach(stickers) { sticker in
                            let baseFont: CGFloat = (sticker.type == .emoji) ? 24 : 12
                            let finalFont = baseFont * sticker.scale * contentScaleFactor
                            
                            Text(sticker.content.isEmpty ? " " : sticker.content)
                                .font(.system(size: finalFont))
                                .fixedSize(horizontal: true, vertical: false)
                                .lineLimit(1)
                                .rotationEffect(.degrees(sticker.rotationDegrees))
                                .position(
                                    x: sticker.posX * w,
                                    y: sticker.posY * h
                                )
                        }
                    }
                    
                    // MARK: Drawing overlay
                    if let img = drawingImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: w, height: h)
                            .clipped()
                            .allowsHitTesting(false)
                    }
                }
            }
            .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit)
            
            // MARK: Day number overlay
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
        .onAppear {
            loadBackgroundImage()
            loadDrawingImage()
        }
        .onTapGesture { onTap?() }
        .onLongPressGesture(minimumDuration: 0.5) { onLongPress?() }
    }
}

// MARK: - Image loading
extension DayCellView {
    
    private func loadBackgroundImage() {
        guard backgroundImage == nil,
              let data = dayEntry?.backgroundImageData else { return }
        
        let key = "bg_\(data.hashValue)"
        if let cached = ImageCache.shared.image(forKey: key) {
            backgroundImage = cached
            return
        }
        
        Task.detached(priority: .userInitiated) {
            if let img = UIImage(data: data) {
                ImageCache.shared.set(img, forKey: key)
                await MainActor.run { backgroundImage = img }
            }
        }
    }
    
    private func loadDrawingImage() {
        guard drawingImage == nil,
              let data = dayEntry?.drawingData else { return }
        
        let key = "draw_\(data.hashValue)"
        if let cached = DrawingCache.shared.image(forKey: key) {
            drawingImage = cached
            return
        }
        
        Task.detached(priority: .userInitiated) {
            guard let drawing = try? PKDrawing(data: data) else { return }
            let rect = CGRect(
                x: 0,
                y: 0,
                width: AppConstants.editorPreviewWidth,
                height: AppConstants.editorPreviewHeight
            )
            let img = drawing.image(from: rect, scale: 1)
            DrawingCache.shared.set(img, forKey: key)
            await MainActor.run { drawingImage = img }
        }
    }
}
