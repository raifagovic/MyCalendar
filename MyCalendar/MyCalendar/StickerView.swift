//
//  StickerView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 6. 9. 2025..
//

import SwiftUI

struct StickerView: View {
    @Binding var sticker: StickerInfo
    var containerSize: CGSize
    @Binding var selectedStickerID: UUID?

    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureOffset: CGSize = .zero
    @GestureState private var gestureRotation: Angle = .zero

    // Extra padding for easier gesture interaction (keeps small emoji usable)
    private let touchPadding: CGFloat = 36

    // selected by comparing IDs (robust across SwiftData rehydration)
    private var isSelected: Bool { selectedStickerID == sticker.id }

    var body: some View {
        let w = containerSize.width
        let h = containerSize.height

        Text(sticker.content.isEmpty ? " " : sticker.content)
            .font(.system(size: sticker.type == .emoji ? 40 : 18))
            .padding(sticker.type == .emoji ? .zero : 4)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
            )
            // Apply rotation & scale (gesture contributions only when selected)
            .rotationEffect(.degrees(sticker.rotationDegrees) + (isSelected ? gestureRotation : .zero))
            .scaleEffect(sticker.scale * (isSelected ? gestureScale : 1.0))
            // position is normalized (0..1)
            .position(
                x: sticker.posX * w + (isSelected ? gestureOffset.width : 0),
                y: sticker.posY * h + (isSelected ? gestureOffset.height : 0)
            )
            // allow easier touches around small stickers
            .contentShape(Rectangle().inset(by: -touchPadding))
            .gesture(
                // enable gestures only when selected — avoids accidental manipulations
                isSelected ? SimultaneousGesture(
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
                            if w > 0 && h > 0 {
                                sticker.posX += value.translation.width / w
                                sticker.posY += value.translation.height / h
                                sticker.posX = min(max(sticker.posX, 0.0), 1.0)
                                sticker.posY = min(max(sticker.posY, 0.0), 1.0)
                            }
                        }
                ) : nil
            )
            .onTapGesture {
                // Select this sticker by ID; tapping it again keeps selection (deselect via tapping outside)
                selectedStickerID = sticker.id
            }
    }
}
