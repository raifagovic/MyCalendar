//
//  StickerView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 6. 9. 2025..
//

import SwiftUI

struct StickerView: View {
    @Binding var sticker: StickerInfo
    @Binding var isSelected: Bool
    var containerSize: CGSize
    
    @State private var dragOffset: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    @State private var gestureRotation: Angle = .zero
    
    var body: some View {
        Text(sticker.text)
            .font(.system(size: 24))
            .padding(4)
            .background(Color.yellow.opacity(0.3))
            .cornerRadius(6)
            .scaleEffect(sticker.scale * currentScale)
            .rotationEffect(Angle(degrees: sticker.rotation) + gestureRotation)
            .position(
                x: CGFloat(sticker.posX) * containerSize.width + dragOffset.width,
                y: CGFloat(sticker.posY) * containerSize.height + dragOffset.height
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        sticker.posX += value.translation.width / containerSize.width
                        sticker.posY += value.translation.height / containerSize.height
                        dragOffset = .zero
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        currentScale = value
                    }
                    .onEnded { value in
                        sticker.scale *= value
                        currentScale = 1.0
                    }
            )
            .gesture(
                RotationGesture()
                    .onChanged { value in
                        gestureRotation = value
                    }
                    .onEnded { value in
                        sticker.rotation += gestureRotation.degrees
                        gestureRotation = .zero
                    }
            )
            .onTapGesture {
                isSelected.toggle()
            }
    }
}
