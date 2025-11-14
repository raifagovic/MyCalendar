//
//  CalendarDay.swift
//  MyCalendar
//
//  Created by Raif Agovic on 4. 8. 2025..
//

//import Foundation
//
//// A simple identifiable wrapper for our calendar days.
//struct CalendarDay: Identifiable, Hashable {
//    let id = UUID() // Guaranteed to be unique for every single instance
//    let date: Date
//    var entry: DayEntry?
//}

// CalendarDay.swift
import Foundation

struct CalendarDay: Identifiable, Hashable {
    // Use the date as identity for stability. For empty placeholders, id is .distantFuture to be unique but predictable.
    let date: Date
    var entry: DayEntry?
    
    // convenience computed id for Identifiable conformance
    var id: Date { date }
    
    // distinguish empty placeholder
    var isRealDay: Bool { date != CalendarDay.placeholderDate }
    
    static let placeholderDate = Date.distantFuture // stable placeholder
    static var empty: CalendarDay { CalendarDay(date: CalendarDay.placeholderDate, entry: nil) }
    
    init(date: Date, entry: DayEntry?) {
        self.date = date
        self.entry = entry
    }
}
