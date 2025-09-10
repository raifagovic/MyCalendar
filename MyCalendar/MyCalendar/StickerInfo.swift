//
//  StickerInfo.swift
//  MyCalendar
//
//  Created by Raif Agovic on 6. 9. 2025..
//

// StickerInfo.swift
import Foundation
import SwiftData
import CoreGraphics

/// Simple sticker types we support today.
enum StickerType: String, Codable {
    case text
    case emoji
}

@Model
final class StickerInfo: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var typeRaw: String
    var content: String

    // Runtime absolute position (points) used inside the editor.
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    var scale: CGFloat = 1.0

    // Normalized position (0..1) saved so sticker displays consistently
    // in both editor and month (scaled) views.
    var relativePosX: CGFloat = 0.5
    var relativePosY: CGFloat = 0.5

    // Relationship back to DayEntry. Keep this as a plain stored var to
    // avoid the circular-macro issue; DayEntry holds the @Relationship.
    var dayEntry: DayEntry?

    init(type: StickerType, content: String) {
        self.typeRaw = type.rawValue
        self.content = content
    }

    var type: StickerType {
        StickerType(rawValue: typeRaw) ?? .text
    }
}




