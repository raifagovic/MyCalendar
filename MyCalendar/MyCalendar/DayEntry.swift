//
//  Item.swift
//  MyCalendar
//
//  Created by Raif Agovic on 3. 7. 2025..
//

import Foundation
import SwiftData
import UIKit

@Model
final class DayEntry: Identifiable {
    @Attribute(.unique) var date: Date
    
    var backgroundImageData: Data?
    var drawingData: Data?
    
    var backgroundImageScale: CGFloat = 1.0
    var backgroundImageOffsetX: CGFloat = 0.0
    var backgroundImageOffsetY: CGFloat = 0.0
    
    @Relationship(deleteRule: .cascade, inverse: \StickerInfo.dayEntry)
    var stickers: [StickerInfo] = []
    
    init(date: Date) {
        self.date = date
    }
}



