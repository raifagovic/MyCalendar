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
    @State private var isShowingYearView = false
    
    private let coordinateSpaceName = "calendarScroll"

    var body: some View {
        ScrollViewReader { proxy in
            Group {
                if isShowingYearView {
                    YearView(
                        year: currentVisibleMonth, // Already correct, ensures YearView shows the year of currentVisibleMonth
                        onMonthTapped: { selectedMonth in
                            self.currentVisibleMonth = selectedMonth
                            withAnimation(.spring()) {
                                isShowingYearView = false
                            }
                            // A small delay for user-driven actions is still good practice.
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                proxy.scrollTo(selectedMonth.startOfMonth, anchor: .top)
                            }
                        },
                        onTodayTapped: {
                            // When tapping "Today" in YearView, we want to go back to the *current month* in the main calendar,
                            // and also update `currentVisibleMonth` to today.
                            self.currentVisibleMonth = Date() // Set to today's month
                            withAnimation(.spring()) {
                                isShowingYearView = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                proxy.scrollTo(Date().startOfMonth, anchor: .top)
                            }
                        }
                    )
                    .ignoresSafeArea(edges: .top)
                    .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity), removal: .scale.combined(with: .opacity)))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            
                            Section(header: StickyHeaderView(
                                currentVisibleMonth: currentVisibleMonth,
                                onTodayTapped: {
                                    // User taps should still have a slight delay for robustness.
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                        withAnimation {
                                            proxy.scrollTo(Date().startOfMonth, anchor: .top)
                                        }
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
                                        // Report the month's offset to the preference key
                                        .background(
                                            GeometryReader { geo in
                                                Color.clear.preference(
                                                    key: MonthOffsetPreferenceKey.self,
                                                    value: [MonthOffset(id: month.startOfMonth, offset: geo.frame(in: .named(coordinateSpaceName)).minY)]
                                                )
                                            }
                                        )
                                }
                            }
                        }
                    }
                    // We remove all failed scroll-tracking logic from the ScrollView itself.
                    .coordinateSpace(name: coordinateSpaceName)
                    .ignoresSafeArea(edges: .top)
                    .background(Color.black)
                    .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity), removal: .scale(scale: 0.8).combined(with: .opacity)))
                    // React to changes in month offsets to update currentVisibleMonth
                    .onPreferenceChange(MonthOffsetPreferenceKey.self) { preferences in
                        // Find the month that is currently closest to the top (minY around 0 or positive)
                        if let visibleMonth = preferences
                            .filter({ $0.offset <= 150 }) // Consider months whose top is within the sticky header's height (150)
                            .sorted(by: { $0.offset > $1.offset }) // Get the one closest to 0 from the positive side
                            .first?
                            .id
                        {
                            if !Calendar.current.isDate(currentVisibleMonth, equalTo: visibleMonth, toGranularity: .month) {
                                currentVisibleMonth = visibleMonth
                            }
                        }
                    }
                }
            }

            .onAppear {
                if months.isEmpty {
                    months = generateMonths()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    currentVisibleMonth = Date().startOfMonth
                    // 👇 Removed selectedDate assignment to prevent auto sheet open
                    proxy.scrollTo(Date().startOfMonth, anchor: .top)
                }
            }
            .onChange(of: months) {
                // ✅ Only scroll when months are populated for the first time
                if !months.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(Date().startOfMonth, anchor: .top)
                    }
                }
            }
            // Pass the currentVisibleMonth to YearView as well
            .onChange(of: isShowingYearView) { oldValue, newValue in
                if newValue == false { // When YearView is dismissed
                    // Ensure currentVisibleMonth is up-to-date with the selected month from YearView
                    // This is handled by the onMonthTapped closure, but good to have a fallback.
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
        let today = Date() // Use the actual current date as the center point
        
        let monthRange = -120...120
        
        for i in monthRange {
            if let month = calendar.date(byAdding: .month, value: i, to: today) {
                result.append(month.startOfMonth)
            }
        }
        return result.sorted() // And sort the result to be sure
    }
}

// MARK: - Scroll Tracking Helpers

struct MonthOffset: Identifiable, Equatable {
    let id: Date // The startOfMonth date for this month
    let offset: CGFloat
}

struct MonthOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: [MonthOffset] = []
    
    static func reduce(value: inout [MonthOffset], nextValue: () -> [MonthOffset]) {
        value.append(contentsOf: nextValue())
    }
}



