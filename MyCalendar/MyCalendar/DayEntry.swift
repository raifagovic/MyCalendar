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
final class DayEntry {
    @Attribute(.unique) var date: Date
    var backgroundImageData: Data?
    
    // --- THE FIX: Restore the simple transform properties ---
    var backgroundImageScale: CGFloat = 1.0
    var backgroundImageOffsetX: CGFloat = 0.0
    var backgroundImageOffsetY: CGFloat = 0.0
    
    // We remove this:
    // var cropRectData: Data?
    
    @Relationship(deleteRule: .cascade, inverse: \EmoticonInfo.dayEntry)
    var emoticons: [EmoticonInfo] = []

    init(date: Date) {
        self.date = date
    }
}
