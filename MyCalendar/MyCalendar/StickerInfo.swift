//
//  StickerInfo.swift
//  MyCalendar
//
//  Created by Raif Agovic on 6. 9. 2025..
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class StickerInfo: Identifiable {
    @Attribute(.unique) var id: UUID
    var typeRaw: String // "text" for now, could support "emoji", "drawing" later
    var content: String
    
    // Absolute position (used at runtime in editor)
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    var scale: CGFloat = 1.0
    
    // Normalized position (saved relative to canvas size 0...1)
    var relativePosX: CGFloat = 0.5
    var relativePosY: CGFloat = 0.5
    
    // Relationship back to day
    @Relationship(inverse: \DayEntry.stickers) var dayEntry: DayEntry?
    
    init(type: StickerType, content: String) {
        self.id = UUID()
        self.typeRaw = type.rawValue
        self.content = content
    }
    
    var type: StickerType {
        StickerType(rawValue: typeRaw) ?? .text
    }
}

enum StickerType: String {
    case text
}




