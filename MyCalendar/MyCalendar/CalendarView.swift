//
//  CalendarView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 4. 7. 2025..
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query(sort: \DayEntry.date) private var dayEntries: [DayEntry]
    
    @State private var months: [Date] = []
    @State private var selectedDate: Date?
    
    @State private var currentVisibleMonth: Date = Date()
    private let coordinateSpaceName = "calendarScroll"

    var body: some View {
        ScrollViewReader { proxy in
            // The ScrollView is now the root view.
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    
                    Section(header: StickyHeaderView(
                        currentVisibleMonth: currentVisibleMonth,
                        onTodayTapped: {
                            // --- CHANGE 1: SCROLL TO THE NEW, DEDICATED ANCHOR ---
                            withAnimation {
                                proxy.scrollTo(Date().startOfMonth, anchor: .top)                            }

                        }
                    )) {
                        ForEach(months, id: \.self) { month in
                            MonthView(monthDate: month, dayEntries: dayEntries, selectedDate: $selectedDate)
                                .id(month.startOfMonth)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear
                                            .preference(
                                                key: VisibleMonthPreferenceKey.self,
                                                // We send a dictionary with this month's date and its frame
                                                value: [month: geometry.frame(in: .named(coordinateSpaceName))]
                                            )
                                    }
                                )
                        }
                    }
                }
            }
            .coordinateSpace(name: coordinateSpaceName)
            .onPreferenceChange(VisibleMonthPreferenceKey.self) { frames in
                
                let closestMonth = frames.min(by: { abs($0.value.minY) < abs($1.value.minY) })
                
                if let newVisibleMonth = closestMonth?.key {
                    // Only update the state if the visible month has actually changed
                    if newVisibleMonth != self.currentVisibleMonth {
                        self.currentVisibleMonth = newVisibleMonth
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .background(Color.black)
            .onAppear {
                if months.isEmpty {
                    months = generateMonths()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    proxy.scrollTo(Date().startOfMonth, anchor: .top)
                }
            }
        }
        .sheet(item: $selectedDate) { date in
            DayDetailView(date: date)
        }
    }

    private func generateMonths() -> [Date] {
        var result: [Date] = []
        let calendar = Calendar.current
        // We get the start of THIS month to use as our center point.
        let today = Date().startOfMonth
        
        // This generates 10 years past and 10 years future correctly.
        let monthRange = -120...120
        
        for i in monthRange {
            if let month = calendar.date(byAdding: .month, value: i, to: today) {
                result.append(month)
            }
        }
        // No need to sort, as this generation method is already ordered.
        return result
    }
}
