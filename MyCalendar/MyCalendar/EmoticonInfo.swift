//
//  EmoticonInfo.swift
//  MyCalendar
//
//  Created by Raif Agovic on 23. 7. 2025..
//

import Foundation
import SwiftData

@Model
final class EmoticonInfo {
    var character: String // The emoticon itself, e.g., "✈️"
    var time: Date?      // The associated time for the pop-up
    // You might add position properties later if you want to drag/drop them
    // var xPosition: Double
    // var yPosition: Double
    
    // This creates a relationship to the DayEntry it belongs to
    var dayEntry: DayEntry?

    init(character: String, time: Date? = nil) {
        self.character = character
        self.time = time
    }
}
