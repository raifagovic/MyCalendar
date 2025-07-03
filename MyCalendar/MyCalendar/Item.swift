//
//  Item.swift
//  MyCalendar
//
//  Created by Raif Agovic on 3. 7. 2025..
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
