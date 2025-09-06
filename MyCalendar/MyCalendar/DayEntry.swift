//
//  Item.swift
//  MyCalendar
//
//  Created by Raif Agovic on 3. 7. 2025..
//

import Foundation
import SwiftData
import UIKit

// MARK: - TextStickerInfo Model
@Model
final class TextStickerInfo {
    @Attribute(.unique) var id = UUID()
    var text: String
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    var scale: CGFloat = 1.0
    
    @Relationship(inverse: \DayEntry.textStickers)
    var dayEntry: DayEntry?
    
    init(text: String, posX: CGFloat = 0.0, posY: CGFloat = 0.0, scale: CGFloat = 1.0) {
        self.text = text
        self.posX = posX
        self.posY = posY
        self.scale = scale
    }
}

// MARK: - EmoticonInfo Model
@Model
final class EmoticonInfo {
    @Attribute(.unique) var id = UUID()
    var character: String
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    var scale: CGFloat = 1.0
    
    @Relationship(inverse: \DayEntry.emoticons)
    var dayEntry: DayEntry?
    
    init(character: String, posX: CGFloat = 0.0, posY: CGFloat = 0.0, scale: CGFloat = 1.0) {
        self.character = character
        self.posX = posX
        self.posY = posY
        self.scale = scale
    }
}

// MARK: - DayEntry Model
@Model
final class DayEntry {
    @Attribute(.unique) var date: Date
    var backgroundImageData: Data?
    var drawingData: Data?
    
    var backgroundImageScale: CGFloat = 1.0
    var backgroundImageOffsetX: CGFloat = 0.0
    var backgroundImageOffsetY: CGFloat = 0.0
    
    // Stickers
    @Relationship(deleteRule: .cascade, inverse: \EmoticonInfo.dayEntry)
    var emoticons: [EmoticonInfo] = []
    
    @Relationship(deleteRule: .cascade, inverse: \TextStickerInfo.dayEntry)
    var textStickers: [TextStickerInfo] = []

    init(date: Date) {
        self.date = date
    }
}

