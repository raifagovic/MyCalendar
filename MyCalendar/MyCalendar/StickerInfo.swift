//
//  StickerInfo.swift
//  MyCalendar
//
//  Created by Raif Agovic on 6. 9. 2025..
//

import SwiftData
import Foundation

@Model
class StickerInfo: Identifiable {
    @Attribute(.unique) var id: UUID
    var text: String
    var posX: Double
    var posY: Double
    var scale: Double
    var rotation: Double   // stored in degrees
    
    init(
        id: UUID = UUID(),
        text: String,
        posX: Double = 0.5,
        posY: Double = 0.5,
        scale: Double = 1.0,
        rotation: Double = 0.0
    ) {
        self.id = id
        self.text = text
        self.posX = posX
        self.posY = posY
        self.scale = scale
        self.rotation = rotation
    }
}







