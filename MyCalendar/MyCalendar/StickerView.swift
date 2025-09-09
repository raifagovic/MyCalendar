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
    
    let containerSize: CGSize  // Pass in parent size for scaling

    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureOffset: CGSize = .zero

    var body: some View {
        Group {
            if sticker.type == .emoji {
                Text(sticker.content)
                    .font(.system(size: 40))
            } else {
                Text(sticker.content.isEmpty ? " " : sticker.content)
                    .padding(4)
            }
        }
        .background(Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
        )
        .scaleEffect(sticker.scale * gestureScale)
        .offset(
            x: sticker.relativePosX * containerSize.width + gestureOffset.width - containerSize.width/2,
            y: sticker.relativePosY * containerSize.height + gestureOffset.height - containerSize.height/2
        )
        .gesture(
            SimultaneousGesture(
                MagnificationGesture()
                    .updating($gestureScale) { value, state, _ in state = value }
                    .onEnded { value in sticker.scale *= value },
                DragGesture()
                    .updating($gestureOffset) { value, state, _ in state = value.translation }
                    .onEnded { value in
                        let newX = sticker.relativePosX * containerSize.width + value.translation.width
                        let newY = sticker.relativePosY * containerSize.height + value.translation.height
                        sticker.relativePosX = newX / containerSize.width
                        sticker.relativePosY = newY / containerSize.height
                    }
            )
        )
        .onTapGesture { isSelected.toggle() }
    }
}
