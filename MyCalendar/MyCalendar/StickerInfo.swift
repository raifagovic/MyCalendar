//
//  StickerInfo.swift
//  MyCalendar
//
//  Created by Raif Agovic on 6. 9. 2025..
//

import Foundation
import SwiftData
import CoreGraphics
import SwiftUI

enum StickerType: String, Codable {
    case text
    case emoji
}

@Model
final class StickerInfo: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var typeRaw: String
    var content: String

    // Position & transform
    var posX: CGFloat = 0.5  // relative to container
    var posY: CGFloat = 0.5
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero

    // Relationship back to day (one-way)
    var dayEntry: DayEntry?

    init(type: StickerType, content: String) {
        self.typeRaw = type.rawValue
        self.content = content
    }

    var type: StickerType {
        StickerType(rawValue: typeRaw) ?? .text
    }
}







