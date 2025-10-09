
//
//  Date+Extensions.swift
//  MyCalendar
//
//  Created by Raif Agovic on 5. 8. 2025..
//

//import Foundation
//
//// This extension adds useful computed properties to the built-in Date type.
//extension Date: Identifiable {
//    
//    var startOfMonth: Date {
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.year, .month], from: self)
//        return calendar.date(from: components) ?? self
//    }
//    
//    // While we're here, let's also restore the Identifiable conformance
//    // in this centralized location.
//    public var id: Date { self }
//}

import Foundation

extension Date: Identifiable {
    public var id: Date { self } // This remains the default

    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    // NEW: A computed property to create a unique ID for the *grid start* of a month
    var gridStartID: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-grid-start"
        return formatter.string(from: self)
    }
}
