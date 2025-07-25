//
//  Item.swift
//  MyCalendar
//
//  Created by Raif Agovic on 3. 7. 2025..
//

import Foundation
import SwiftData
import UIKit // Needed for UIImage data

@Model
final class DayEntry {
    @Attribute(.unique) var date: Date // Use a specific date as a unique ID
    var backgroundImageData: Data?     // To store the background photo
    var drawingData: Data?             // To store the PKDrawing
    
    var backgroundImageScale: CGFloat = 1.0 // 1.0 means no zoom
    var backgroundImageOffsetX: CGFloat = 0.0 // 0.0 means centered
    var backgroundImageOffsetY: CGFloat = 0.0 // 0.0 means centered
    
    // This sets up a one-to-many relationship with EmoticonInfo
    @Relationship(deleteRule: .cascade, inverse: \EmoticonInfo.dayEntry)
    var emoticons: [EmoticonInfo] = []

    init(date: Date) {
        self.date = date
    }
}
