//
//  CalendarView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 4. 7. 2025..
//
//
//import SwiftUI
//import SwiftData
//
//struct CalendarView: View {
//    @Query(sort: \DayEntry.date) private var dayEntries: [DayEntry]
//    
//    @State private var months: [Date] = []
//    @State private var selectedDate: Date? // This is used for DayDetailView, a short tap
//    
//    // track by index so we can scrollTo an index directly
//    @State private var currentVisibleMonthIndex: Int = 0
//    @State private var isShowingYearView = false
//  
//    @State private var showingNotificationsSheet = false
//    @State private var selectedDateForNotifications: Date? = nil
//    
//    private let coordinateSpaceName = "calendarScroll"
//
//    var body: some View {
//        ScrollViewReader { proxy in
//            Group {
//                if isShowingYearView {
//                    YearView(
//                        year: months.isEmpty ? Date() : months[currentVisibleMonthIndex],
//                        onMonthTapped: { selectedMonth in
//                            // find index for selectedMonth and scroll to it
//                            if let idx = months.firstIndex(of: selectedMonth.startOfMonth) {
//                                currentVisibleMonthIndex = idx
//                                withAnimation(.spring()) {
//                                    isShowingYearView = false
//                                }
//                                DispatchQueue.main.async {
//                                    proxy.scrollTo(idx, anchor: .top)
//                                }
//                            } else {
//                                // fallback: close year view and set visible month
//                                currentVisibleMonthIndex = months.firstIndex(of: Date().startOfMonth) ?? 0
//                                withAnimation(.spring()) { isShowingYearView = false }
//                            }
//                        },
//                        onTodayTapped: {
//                            let todayStart = Date().startOfMonth
//                            if let idx = months.firstIndex(of: todayStart) {
//                                currentVisibleMonthIndex = idx
//                                withAnimation(.spring()) {
//                                    isShowingYearView = false
//                                }
//                                DispatchQueue.main.async {
//                                    proxy.scrollTo(idx, anchor: .top)
//                                }
//                            } else {
//                                // if today's month not in range, just set visibleMonth to closest
//                                currentVisibleMonthIndex = months.count / 2
//                                withAnimation(.spring()) { isShowingYearView = false }
//                            }
//                        }
//                    )
//                    .ignoresSafeArea(edges: .top)
//                    .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity),
//                                            removal: .scale.combined(with: .opacity)))
//                } else {
//                    ScrollView {
//                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
//                            
//                            Section(header: StickyHeaderView(
//                                currentVisibleMonth: months.isEmpty ? Date() : months[currentVisibleMonthIndex],
//                                onTodayTapped: {
//                                    if let todayIdx = months.firstIndex(of: Date().startOfMonth) {
//                                        withAnimation {
//                                            proxy.scrollTo(todayIdx, anchor: .top)
//                                        }
//                                    }
//                                },
//                                onYearTapped: {
//                                    withAnimation(.spring()) {
//                                        isShowingYearView = true
//                                    }
//                                }
//                            )) {
//                                // Use enumerated months so IDs are integers (stable for scrollTo)
//                                ForEach(Array(months.enumerated()), id: \.0) { index, month in
//                                    MonthView(
//                                        monthDate: month,
//                                        dayEntries: dayEntries,
//                                        selectedDate: $selectedDate,
//                                        onLongPressDay: { date in
//                                            self.selectedDateForNotifications = date
//                                            self.showingNotificationsSheet = true
//                                        }
//                                    )
//                                    .id(index) // id is index so we can scrollTo index directly
//                                    .background(
//                                        GeometryReader { geo in
//                                            Color.clear.preference(
//                                                key: MonthOffsetPreferenceKey.self,
//                                                value: [MonthOffset(id: month, offset: geo.frame(in: .named(coordinateSpaceName)).minY)]
//                                            )
//                                        }
//                                    )
//                                }
//                            }
//                        }
//                    }
//                    .coordinateSpace(name: coordinateSpaceName)
//                    .ignoresSafeArea(edges: .top)
//                    .background(Color.black)
//                    .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity),
//                                            removal: .scale(scale: 0.8).combined(with: .opacity)))
//                    .onPreferenceChange(MonthOffsetPreferenceKey.self) { preferences in
//                        // Determine visible month date and map to index
//                        if let visibleMonth = preferences
//                            .filter({ $0.offset <= 150 })
//                            .sorted(by: { $0.offset > $1.offset })
//                            .first?
//                            .id
//                        {
//                            let startMonth = visibleMonth.startOfMonth
//                            if let idx = months.firstIndex(of: startMonth),
//                               idx != currentVisibleMonthIndex {
//                                currentVisibleMonthIndex = idx
//                            }
//                        }
//                    }
//                }
//            }
//            .onAppear {
//                if months.isEmpty {
//                    // Build 10 years back and 10 years forward (inclusive) in months
//                    let calendar = Calendar.current
//                    let today = Date()
//                    let startYearDate = calendar.date(byAdding: .year, value: -10, to: today)!
//                    let endYearDate = calendar.date(byAdding: .year, value: 10, to: today)!
//                    
//                    var tmp: [Date] = []
//                    var cursor = startYearDate.startOfMonth
//                    let endCursor = endYearDate.startOfMonth
//                    while cursor <= endCursor {
//                        tmp.append(cursor)
//                        cursor = calendar.date(byAdding: .month, value: 1, to: cursor)!
//                    }
//                    months = tmp
//                    
//                    // compute index for current month and jump to it
//                    let currentStart = today.startOfMonth
//                    if let idx = months.firstIndex(of: currentStart) {
//                        currentVisibleMonthIndex = idx
//                        // Scroll to index after layout — use async to ensure LazyVStack has laid out the ID anchors.
//                        DispatchQueue.main.async {
//                            proxy.scrollTo(idx, anchor: .top)
//                        }
//                    } else {
//                        currentVisibleMonthIndex = months.count / 2
//                    }
//                }
//            }
//            .onChange(of: isShowingYearView) { oldValue, newValue in
//                // kept for clarity (no-op)
//            }
//        }
//        .sheet(item: $selectedDate) { date in
//            DayDetailView(date: date)
//        }
//        .sheet(item: $selectedDateForNotifications) { date in
//            DayNotificationsView(date: date)
//        }
//    }
//}

import SwiftUI
import SwiftData // Keep this import

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext // ✅ Keep modelContext
    
    // REMOVE THIS LINE:
    // @Query(sort: \DayEntry.date) private var dayEntries: [DayEntry] // ❌ DELETE THIS LINE

    @State private var months: [Date] = []
    @State private var selectedDate: Date? // This is used for DayDetailView, a short tap
    
    // track by index so we can scrollTo an index directly
    @State private var currentVisibleMonthIndex: Int = 0
    @State private var isShowingYearView = false
  
    @State private var showingNotificationsSheet = false
    @State private var selectedDateForNotifications: Date? = nil
    
    private let coordinateSpaceName = "calendarScroll"

    var body: some View {
        ScrollViewReader { proxy in
            Group {
                if isShowingYearView {
                    YearView(
                        year: months.isEmpty ? Date() : months[currentVisibleMonthIndex],
                        onMonthTapped: { selectedMonth in
                            if let idx = months.firstIndex(of: selectedMonth.startOfMonth) {
                                currentVisibleMonthIndex = idx
                                withAnimation(.spring()) {
                                    isShowingYearView = false
                                }
                                DispatchQueue.main.async {
                                    proxy.scrollTo(idx, anchor: .top)
                                }
                            } else {
                                currentVisibleMonthIndex = months.firstIndex(of: Date().startOfMonth) ?? 0
                                withAnimation(.spring()) { isShowingYearView = false }
                            }
                        },
                        onTodayTapped: {
                            let todayStart = Date().startOfMonth
                            if let idx = months.firstIndex(of: todayStart) {
                                currentVisibleMonthIndex = idx
                                withAnimation(.spring()) {
                                    isShowingYearView = false
                                }
                                DispatchQueue.main.async {
                                    proxy.scrollTo(idx, anchor: .top)
                                }
                            } else {
                                currentVisibleMonthIndex = months.count / 2
                                withAnimation(.spring()) { isShowingYearView = false }
                            }
                        }
                    )
                    .ignoresSafeArea(edges: .top)
                    .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity),
                                            removal: .scale.combined(with: .opacity)))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            
                            Section(header: StickyHeaderView(
                                currentVisibleMonth: months.isEmpty ? Date() : months[currentVisibleMonthIndex],
                                onTodayTapped: {
                                    if let todayIdx = months.firstIndex(of: Date().startOfMonth) {
                                        withAnimation {
                                            proxy.scrollTo(todayIdx, anchor: .top)
                                        }
                                    }
                                },
                                onYearTapped: {
                                    withAnimation(.spring()) {
                                        isShowingYearView = true
                                    }
                                }
                            )) {
                                ForEach(Array(months.enumerated()), id: \.0) { index, month in
                                    MonthView(
                                        monthDate: month,
                                        // REMOVE THIS LINE (as we pass dayEntries through the init for MonthView):
                                        // dayEntries: dayEntries, // ❌ DELETE THIS PARAMETER
                                        selectedDate: $selectedDate,
                                        onLongPressDay: { date in
                                            self.selectedDateForNotifications = date
                                            self.showingNotificationsSheet = true
                                        }
                                    )
                                    .id(index)
                                    .background(
                                        GeometryReader { geo in
                                            Color.clear.preference(
                                                key: MonthOffsetPreferenceKey.self,
                                                value: [MonthOffset(id: month, offset: geo.frame(in: .named(coordinateSpaceName)).minY)]
                                            )
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .coordinateSpace(name: coordinateSpaceName)
                    .ignoresSafeArea(edges: .top)
                    .background(Color.black)
                    .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity),
                                            removal: .scale(scale: 0.8).combined(with: .opacity)))
                    .onPreferenceChange(MonthOffsetPreferenceKey.self) { preferences in
                        if let visibleMonth = preferences
                            .filter({ $0.offset <= 150 })
                            .sorted(by: { $0.offset > $1.offset })
                            .first?
                            .id
                        {
                            let startMonth = visibleMonth.startOfMonth
                            if let idx = months.firstIndex(of: startMonth),
                               idx != currentVisibleMonthIndex {
                                currentVisibleMonthIndex = idx
                            }
                        }
                    }
                }
            }
            .onAppear {
                if months.isEmpty {
                    let calendar = Calendar.current
                    let today = Date()
                    let startYearDate = calendar.date(byAdding: .year, value: -10, to: today)!
                    let endYearDate = calendar.date(byAdding: .year, value: 10, to: today)!
                    
                    var tmp: [Date] = []
                    var cursor = startYearDate.startOfMonth
                    let endCursor = endYearDate.startOfMonth
                    while cursor <= endCursor {
                        tmp.append(cursor)
                        cursor = calendar.date(byAdding: .month, value: 1, to: cursor)!
                    }
                    months = tmp
                    
                    let currentStart = today.startOfMonth
                    if let idx = months.firstIndex(of: currentStart) {
                        currentVisibleMonthIndex = idx
                        DispatchQueue.main.async {
                            proxy.scrollTo(idx, anchor: .top)
                        }
                    } else {
                        currentVisibleMonthIndex = months.count / 2
                    }
                }
            }
            .onChange(of: isShowingYearView) { oldValue, newValue in
                // kept for clarity (no-op)
            }
        }
        .sheet(item: $selectedDate) { date in
            DayDetailView(date: date)
                .environment(\.modelContext, modelContext) // ✅ ADD THIS BACK if you removed it
        }
        .sheet(item: $selectedDateForNotifications) { date in
            DayNotificationsView(date: date)
                .environment(\.modelContext, modelContext) // ✅ ADD THIS BACK if you removed it
        }
    }
}

// ... rest of file (MonthOffset, MonthOffsetPreferenceKey) ...

// MARK: - Scroll Tracking Helpers

struct MonthOffset: Identifiable, Equatable {
    let id: Date
    let offset: CGFloat
}

struct MonthOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: [MonthOffset] = []
    
    static func reduce(value: inout [MonthOffset], nextValue: () -> [MonthOffset]) {
        value.append(contentsOf: nextValue())
    }
}
