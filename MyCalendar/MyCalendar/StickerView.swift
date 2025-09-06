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
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
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
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
        )
        .scaleEffect(scale * gestureScale)
        .offset(x: offset.width + gestureOffset.width,
                y: offset.height + gestureOffset.height)
        .gesture(
            SimultaneousGesture(
                MagnificationGesture()
                    .updating($gestureScale) { value, state, _ in state = value }
                    .onEnded { value in scale *= value },
                DragGesture()
                    .updating($gestureOffset) { value, state, _ in state = value.translation }
                    .onEnded { value in
                        offset.width += value.translation.width
                        offset.height += value.translation.height
                    }
            )
        )
        .onTapGesture {
            isSelected.toggle()
        }
    }
}
