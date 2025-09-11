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

    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureOffset: CGSize = .zero
    @GestureState private var gestureRotation: Angle = .zero

    var body: some View {
        let w = containerSize.width
        let h = containerSize.height

        Group {
            Text(sticker.content.isEmpty ? " " : sticker.content)
                .font(.system(size: sticker.type == .emoji ? 40 : 18))
                .padding(sticker.type == .emoji ? .zero : 4)
        }
        .background(Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
        )
        // Apply rotation & scale
        .rotationEffect(.degrees(sticker.rotationDegrees) + gestureRotation)
        .scaleEffect(sticker.scale * gestureScale)
        // Position is normalized (0..1)
        .position(
            x: sticker.posX * w + gestureOffset.width,
            y: sticker.posY * h + gestureOffset.height
        )
        .gesture(
            // nest SimultaneousGesture so we can combine three gestures
            SimultaneousGesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .updating($gestureScale) { value, state, _ in state = value }
                        .onEnded { value in sticker.scale *= value },
                    RotationGesture()
                        .updating($gestureRotation) { value, state, _ in state = value }
                        .onEnded { value in sticker.rotationDegrees += value.degrees }
                ),
                DragGesture()
                    .updating($gestureOffset) { value, state, _ in state = value.translation }
                    .onEnded { value in
                        // translate absolute translation -> normalized pos
                        if w > 0 && h > 0 {
                            sticker.posX += value.translation.width / w
                            sticker.posY += value.translation.height / h
                            // clamp 0..1 if desired:
                            sticker.posX = min(max(sticker.posX, 0.0), 1.0)
                            sticker.posY = min(max(sticker.posY, 0.0), 1.0)
                        }
                    }
            )
        )
        .onTapGesture {
            isSelected.toggle()
        }
    }
}

