//
//  StickerInfo.swift
//  MyCalendar
//
//  Created by Raif Agovic on 6. 9. 2025..
//

import Foundation
import SwiftData
import CoreGraphics

@Model
final class StickerInfo {
    enum StickerType: String, Codable {
        case text
        case emoji
    }

    var type: StickerType
    var content: String

    // Relative positioning (0.0…1.0)
    var relativePosX: CGFloat = 0.5
    var relativePosY: CGFloat = 0.5
    var scale: CGFloat = 1.0

    // Relationship back to DayEntry
    var dayEntry: DayEntry?

    init(type: StickerType,
         content: String,
         relativePosX: CGFloat = 0.5,
         relativePosY: CGFloat = 0.5,
         scale: CGFloat = 1.0) {
        self.type = type
        self.content = content
        self.relativePosX = relativePosX
        self.relativePosY = relativePosY
        self.scale = scale
    }
}


