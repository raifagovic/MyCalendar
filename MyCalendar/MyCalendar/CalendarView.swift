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
                            withAnimation {
                                proxy.scrollTo(Date().startOfMonth, anchor: .top)
                            }
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
            // --- CHANGE 4: Apply the coordinate space and listener to the ScrollView ---
            .coordinateSpace(name: coordinateSpaceName)
            .onPreferenceChange(VisibleMonthPreferenceKey.self) { frames in
                // This code runs every time the user scrolls and a frame changes.
                // We find the month whose top edge is closest to the top of the scroll view.
                let topEdge: CGFloat = 20 // A small offset to account for the header area
                
                let closestMonth = frames
                    // Consider only months whose top edge is near or above the top of the screen
                //                    .filter { $0.value.minY < topEdge }
                    // Find the one whose top edge is closest to the top
                    .min(by: { abs($0.value.minY - topEdge) < abs($1.value.minY - topEdge) })
                
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
                DispatchQueue.main.async {
                    proxy.scrollTo(Date().startOfMonth, anchor: .top)
                }
            }
        }
        .sheet(item: $selectedDate) { date in
            DayDetailView(date: date)
        }
    }

    private func generateMonths() -> [Date] {
        // ... (this function does not need to change)
        var result: [Date] = []
        let calendar = Calendar.current
        let today = Date()
        let monthRange = -120...120
        
        for i in monthRange {
            if let month = calendar.date(byAdding: .month, value: i, to: today) {
                result.append(month.startOfMonth)
            }
        }
        return result.sorted()
    }
}
