//
//  Extensions.swift
//  MyCalendar
//
//  Created by Raif Agovic on 5. 11. 2025..
//

// NEW CODE (This will be the complete content of your new Extensions.swift file)
import Foundation

// MARK: - Calendar Extensions
extension Calendar {
    static let currentKorean: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        return calendar
    }()

    func startOfDay(for date: Date) -> Date {
        return self.date(from: dateComponents([.year, .month, .day], from: date))!
    }

    func startOfMonth(for date: Date) -> Date {
        return self.date(from: dateComponents([.year, .month], from: date))!
    }
    
    func endOfMonth(for date: Date) -> Date {
        let start = startOfMonth(for: date)
        let plusOneMonth = self.date(byAdding: .month, value: 1, to: start)!
        return self.date(byAdding: .day, value: -1, to: plusOneMonth)!
    }

    func numberOfDays(inMonth date: Date) -> Int {
        return range(of: .day, in: .month, for: date)?.count ?? 0
    }
    
    func isDate(_ date1: Date, inSameMonthAs date2: Date) -> Bool {
        return isDate(date1, equalTo: date2, toGranularity: .month)
    }
    
    // You can add more helpful extensions here as needed
}

// MARK: - Date Extensions
extension Date: Identifiable {
    
    // Existing Identifiable conformance
    public var id: Date { self }

    // Existing startOfMonth, now using the Calendar extension for consistency
    var startOfMonth: Date {
        return Calendar.current.startOfMonth(for: self)
    }
    
    // New properties
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfMonth: Date {
        return Calendar.current.endOfMonth(for: self)
    }

    var day: Int {
        return Calendar.current.component(.day, from: self)
    }

    var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    func isSameDay(as otherDate: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: otherDate)
    }
    
    func isSameMonth(as otherDate: Date) -> Bool {
        return Calendar.current.isDate(self, inSameMonthAs: otherDate)
    }
}
