//
//  StickerView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 5. 8. 2025..
//

import SwiftUI

struct StickerView: View {
    let sticker: StickerInfo
    var containerSize: CGSize
    var isSelected: Bool

    var body: some View {
        Text(sticker.content.isEmpty ? " " : sticker.content)
            .font(.system(size: sticker.type == .emoji ? 40 : 18))
            .padding(sticker.type == .emoji ? .zero : 4)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
            )
            .rotationEffect(.degrees(sticker.rotationDegrees))
            .scaleEffect(sticker.scale)
            .position(
                x: sticker.posX * containerSize.width,
                y: sticker.posY * containerSize.height
            )
    }
}
