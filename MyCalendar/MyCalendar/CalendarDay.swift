//
//  CalendarDay.swift
//  MyCalendar
//
//  Created by Raif Agovic on 4. 8. 2025..
//

import Foundation

// A simple identifiable wrapper for our calendar days.
struct CalendarDay: Identifiable, Hashable {
    let id = UUID() // Guaranteed to be unique for every single instance
    let date: Date
}
