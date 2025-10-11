//
//  NotificationEntry.swift
//  MyCalendar
//
//  Created by Raif Agovic on 12. 10. 2025..
//

import Foundation
import SwiftData

@Model
final class NotificationEntry {
    var id: UUID
    var date: Date // The date this notification belongs to
    var time: Date // The time of the notification
    var label: String
    
    init(date: Date, time: Date, label: String) {
        self.id = UUID()
        self.date = date
        self.time = time
        self.label = label
    }
}
