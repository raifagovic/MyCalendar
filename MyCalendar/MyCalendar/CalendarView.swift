//
//  CalendarView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 4. 7. 2025..
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    // ... all properties are unchanged ...
    @Query(sort: \DayEntry.date) private var dayEntries: [DayEntry]
    
    @State private var months: [Date] = []
    @State private var selectedDate: Date?
    
    @State private var currentVisibleMonth: Date = Date()
    @State private var isShowingYearView = false
    
    private let coordinateSpaceName = "calendarScroll"

    var body: some View {
        ScrollViewReader { proxy in
            
            if isShowingYearView {
                YearView(
                    year: currentVisibleMonth,
                    onMonthTapped: { selectedMonth in
                        self.currentVisibleMonth = selectedMonth
                        withAnimation(.spring()) {
                            isShowingYearView = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            proxy.scrollTo(selectedMonth.startOfMonth, anchor: .top)
                        }
                    },
                    // --- PROVIDE THE ACTION FOR THE "TODAY" BUTTON ---
                    onTodayTapped: {
                        // 1. Ensure the month is set to today
                        self.currentVisibleMonth = Date()
                        // 2. Animate back to the main calendar view
                        withAnimation(.spring()) {
                            isShowingYearView = false
                        }
                        // 3. Trigger the scroll to today's date in the main view
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                             proxy.scrollTo(Date().startOfMonth, anchor: .top)
                        }
                    }
                )
                .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity), removal: .scale.combined(with: .opacity)))
            } else {
                // ... your main ScrollView code is unchanged ...
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        
                        Section(header: StickyHeaderView(
                            currentVisibleMonth: currentVisibleMonth,
                            onTodayTapped: {
                                withAnimation {
                                    proxy.scrollTo(Date().startOfMonth, anchor: .top)
                                }
                            },
                            onYearTapped: {
                                withAnimation(.spring()) {
                                    isShowingYearView = true
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
                        if newVisibleMonth != self.currentVisibleMonth {
                            self.currentVisibleMonth = newVisibleMonth
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)
                .background(Color.black)
                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale(scale: 0.8).combined(with: .opacity)))
            }
        }
        .onAppear {
            if months.isEmpty {
                months = generateMonths()
            }
        }
        .sheet(item: $selectedDate) { date in
            DayDetailView(date: date)
        }
    }

    private func generateMonths() -> [Date] {
        // ... This function is unchanged ...
        var result: [Date] = []
        let calendar = Calendar.current
        let today = Date().startOfMonth
        
        let monthRange = -120...120
        
        for i in monthRange {
            if let month = calendar.date(byAdding: .month, value: i, to: today) {
                result.append(month)
            }
        }
        return result
    }
}
