//
//  WeekRowView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 4. 8. 2025..
//

import SwiftUI
import SwiftData

struct WeekRowView: View {
    let week: [CalendarDay]
    let dayEntries: [DayEntry]
    @Binding var selectedDate: Date? // For DayDetailView
    @State private var selectedDateForNotifications: Date? // For DayNotificationsView
    @State private var showingNotificationsSheet = false // for long-press popup
    
    let monthDate: Date
    let isFirstContentWeek: Bool
    let firstDayOfCurrentMonth: CalendarDay?
    
    private var isCurrentMonth: Bool {
        Calendar.current.isDate(monthDate, equalTo: Date(), toGranularity: .month)
    }
    
    private var monthAbbreviationFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }
    
    @ViewBuilder
    private func dayCell(for day: CalendarDay) -> some View {
        if day.date == Date.distantPast {
            Rectangle().fill(Color.clear)
        } else {
            DayCellView(
                day: day.date,
                dayEntry: dayEntries.first {
                    Calendar.current.isDate($0.date, inSameDayAs: day.date)
                },
                onTap: { self.selectedDate = day.date },
                onLongPress: {
                    self.selectedDateForNotifications = day.date
                    self.showingNotificationsSheet = true
                }
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // --- Header divider logic ---
            if isFirstContentWeek {
                ZStack {
                    HStack(spacing: 0) {
                        ForEach(week) { day in
                            Rectangle()
                                .fill(day.date != .distantPast ? Color.gray.opacity(0.5) : Color.clear)
                                .frame(height: 1)
                        }
                    }
                    HStack(spacing: 0) {
                        ForEach(week) { day in
                            if day.date != .distantPast &&
                                Calendar.current.component(.day, from: day.date) == 1 {
                                Text(monthAbbreviationFormatter.string(from: monthDate))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(
                                        Calendar.current.isDate(monthDate, equalTo: Date(), toGranularity: .month)
                                        ? .red : .primary
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
                HStack(spacing: 0) {
                    ForEach(week) { day in
                        Rectangle()
                            .fill(day.date != .distantPast ? Color.gray.opacity(0.5) : Color.clear)
                            .frame(height: 1)
                    }
                }
            }
            
            // --- Day cells row ---
            HStack(spacing: 0) {
                ForEach(week) { day in
                    dayCell(for: day)
                }
            }
        }
        .sheet(isPresented: $showingNotificationsSheet) {
            if let date = selectedDateForNotifications {
                DayNotificationsView(date: date)
            }
        }
    }
}
