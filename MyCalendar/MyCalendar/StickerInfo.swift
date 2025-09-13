//
//  StickerInfo.swift
//  MyCalendar
//
//  Created by Raif Agovic on 6. 9. 2025..
//

import Foundation
import SwiftData
import CoreGraphics

enum StickerType: String, Codable {
    case text
    case emoji
}

@Model
final class StickerInfo: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var typeRaw: String
    var content: String

    // Normalized position (0..1)
    var posX: CGFloat = 0.5
    var posY: CGFloat = 0.5
    var scale: CGFloat = 1.0

    // Rotation stored as degrees (Double) — safe for SwiftData
    var rotationDegrees: Double = 0.0

    // Normalized position for persistence if needed
    var relativePosX: CGFloat = 0.5
    var relativePosY: CGFloat = 0.5

    // Plain reference to the parent (avoid circular macro)
    var dayEntry: DayEntry?

    init(type: StickerType, content: String) {
        self.typeRaw = type.rawValue
        self.content = content
    }

    var type: StickerType {
        StickerType(rawValue: typeRaw) ?? .text
    }
}







