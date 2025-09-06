//
//  StickerInfo.swift
//  MyCalendar
//
//  Created by Raif Agovic on 6. 9. 2025..
//

import Foundation
import SwiftData

@Model
final class StickerInfo {
    enum StickerType: String, Codable {
        case text
        case emoji
    }
    
    var type: StickerType
    var content: String          // Either text or emoji characters
    
    // Positioning and transform
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    var scale: CGFloat = 1.0
    
    // (Optional) Rotation if you add it later
    // var rotation: Double = 0.0
    
    // Relationship back to DayEntry
    var dayEntry: DayEntry?
    
    init(type: StickerType,
         content: String,
         posX: CGFloat = 0.0,
         posY: CGFloat = 0.0,
         scale: CGFloat = 1.0) {
        self.type = type
        self.content = content
        self.posX = posX
        self.posY = posY
        self.scale = scale
    }
}

