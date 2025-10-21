//
//  MonthData.swift
//  MyCalendar
//
//  Created by Raif Agovic on 21. 10. 2025..
//

import Foundation

struct MonthData: Identifiable {
    let id: Date
    let weeks: [[CalendarDay]]
    let dayEntries: [DayEntry]
}
