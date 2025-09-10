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
    
    var body: some View {
        let w = containerSize.width
        let h = containerSize.height
        
        Group {
            Text(sticker.content.isEmpty ? " " : sticker.content)
                .font(.system(size: sticker.type == .emoji ? 40 : 18))
                .padding(sticker.type == .emoji ? .zero : 4)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
        )
        .scaleEffect(sticker.scale * gestureScale)
        .position(
            x: sticker.posX * w + gestureOffset.width,
            y: sticker.posY * h + gestureOffset.height
        )
        .gesture(
            SimultaneousGesture(
                MagnificationGesture()
                    .updating($gestureScale) { value, state, _ in state = value }
                    .onEnded { value in
                        sticker.scale *= value
                    },
                DragGesture()
                    .updating($gestureOffset) { value, state, _ in state = value.translation }
                    .onEnded { value in
                        sticker.posX += value.translation.width / w
                        sticker.posY += value.translation.height / h
                    }
            )
        )
        .onTapGesture {
            isSelected.toggle()
        }
    }
}
