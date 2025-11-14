//
//  WeekRowView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 4. 8. 2025..
//

//import SwiftUI
//import SwiftData
//
//struct WeekRowView: View {
//    let week: [CalendarDay]
//    let dayEntries: [DayEntry]
//    @Binding var selectedDate: Date?
//    
//    // ✅ We remove local sheet state — handled by MonthView
//    let monthDate: Date
//    let isFirstContentWeek: Bool
//    let firstDayOfCurrentMonth: CalendarDay?
//    let onLongPressDay: (Date) -> Void  // 👈 callback to MonthView
//    
//    private static let monthAbbreviationFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM"
//        return formatter
//    }()
//    
//    private var monthAbbreviationFormatter: DateFormatter { WeekRowView.monthAbbreviationFormatter }
//    
//    @ViewBuilder
//    private func dayCell(for day: CalendarDay) -> some View {
//        if day.date == Date.distantPast {
//            Rectangle().fill(Color.clear)
//        } else {
//            DayCellView(
//                day: day.date,
//                dayEntry: day.entry,
//                onTap: { self.selectedDate = day.date },
//                onLongPress: { onLongPressDay(day.date) } // ✅ calls up to MonthView
//            )
//        }
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // --- Header divider logic ---
//            if isFirstContentWeek {
//                ZStack {
//                    HStack(spacing: 0) {
//                        ForEach(week) { day in
//                            Rectangle()
//                                .fill(day.date != .distantPast ? Color.gray.opacity(0.5) : Color.clear)
//                                .frame(height: 1)
//                        }
//                    }
//                    HStack(spacing: 0) {
//                        ForEach(week) { day in
//                            if day.date != .distantPast &&
//                                Calendar.current.component(.day, from: day.date) == 1 {
//                                Text(monthAbbreviationFormatter.string(from: monthDate))
//                                    .font(.title3)
//                                    .fontWeight(.bold)
//                                    .foregroundColor(
//                                        monthDate.isSameMonth(as: Date())
//                                        ? .red : .primary
//                                    )
//                                    .offset(y: -22)
//                                    .frame(maxWidth: .infinity, alignment: .center)
//                            } else {
//                                Color.clear
//                            }
//                        }
//                    }
//                }
//            } else if week.contains(where: { $0.date != .distantPast }) {
//                HStack(spacing: 0) {
//                    ForEach(week) { day in
//                        Rectangle()
//                            .fill(day.date != .distantPast ? Color.gray.opacity(0.5) : Color.clear)
//                            .frame(height: 1)
//                    }
//                }
//            }
//
//            // --- Day cells row ---
//            HStack(spacing: 0) {
//                ForEach(week) { day in
//                    dayCell(for: day)
//                }
//            }
//        }
//    }
//}

import SwiftUI

struct WeekRowView: View {
    let week: [CalendarDay]
    @Binding var selectedDate: Date?
    
    let monthDate: Date
    let isFirstContentWeek: Bool
    let firstDayOfCurrentMonth: CalendarDay?
    let onLongPressDay: (Date) -> Void  // callback up to MonthView
    
    // Cached shared formatter
    private static let monthAbbreviationFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()
    
    private var monthAbbreviationFormatter: DateFormatter {
        WeekRowView.monthAbbreviationFormatter
    }

    @ViewBuilder
    private func dayCell(for day: CalendarDay) -> some View {
        if day.date == Date.distantPast {
            Rectangle().fill(Color.clear)
        } else {
            DayCellView(
                day: day.date,
                dayEntry: day.entry,  // ← simplified: entry is already inside CalendarDay
                onTap: { self.selectedDate = day.date },
                onLongPress: { onLongPressDay(day.date) }
            )
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: Header Lines / Month Label
            if isFirstContentWeek {
                ZStack {
                    // main horizontal line
                    HStack(spacing: 0) {
                        ForEach(week) { day in
                            Rectangle()
                                .fill(day.date != .distantPast ? Color.gray.opacity(0.5) : Color.clear)
                                .frame(height: 1)
                        }
                    }

                    // Month abbreviation
                    HStack(spacing: 0) {
                        ForEach(week) { day in
                            if day.date != .distantPast &&
                                Calendar.current.component(.day, from: day.date) == 1 {
                                
                                Text(monthAbbreviationFormatter.string(from: monthDate))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(
                                        monthDate.isSameMonth(as: Date())
                                        ? .red
                                        : .primary
                                    )
                                    .offset(y: -22)
                                    .frame(maxWidth: .infinity, alignment: .center)

                            } else {
                                Color.clear
                            }
                        }
                    }
                }
                
            } else if week.contains(where: { $0.date != .distantPast }) {
                // secondary week top line
                HStack(spacing: 0) {
                    ForEach(week) { day in
                        Rectangle()
                            .fill(day.date != .distantPast ? Color.gray.opacity(0.5) : Color.clear)
                            .frame(height: 1)
                    }
                }
            }

            // MARK: Day Cells Row
            HStack(spacing: 0) {
                ForEach(week) { day in
                    dayCell(for: day)
                }
            }
        }
    }
}
