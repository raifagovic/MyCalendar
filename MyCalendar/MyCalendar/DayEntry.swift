//
//  Item.swift
//  MyCalendar
//
//  Created by Raif Agovic on 3. 7. 2025..
//

import Foundation
import SwiftData
import CoreGraphics
import PencilKit

@Model
final class DayEntry {
    // Unique identifier: the date itself
    @Attribute(.unique) var date: Date

    // Background image
    var backgroundImageData: Data?
    var drawingData: Data? // optional, for PencilKit later

    // Transform state for background
    var backgroundImageScale: CGFloat = 1.0
    var backgroundImageOffsetX: CGFloat = 0.0
    var backgroundImageOffsetY: CGFloat = 0.0

    // Stickers (both text + emoji)
    @Relationship(deleteRule: .cascade)
    var stickers: [StickerInfo] = []

    init(date: Date) {
        self.date = date
    }
}




