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
            // The Group is necessary to keep .onAppear and .onChange in scope.
            Group {
                if isShowingYearView {
                    YearView(
                        year: currentVisibleMonth,
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
                            self.currentVisibleMonth = Date()
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
                                }
                            }
                        }
                    }
                    // We remove all failed scroll-tracking logic from the ScrollView itself.
                    .ignoresSafeArea(edges: .top)
                    .background(Color.black)
                    .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity), removal: .scale(scale: 0.8).combined(with: .opacity)))
                }
            }
            .onAppear {
                // This modifier's ONLY job is to load the data.
                if months.isEmpty {
                    months = generateMonths()
                }
            }
            // --- THE DEFINITIVE FIX ---
            // This modifier watches the `months` array.
            .onChange(of: months) {
                // When the data is loaded, THEN we scroll.
                proxy.scrollTo(Date().startOfMonth, anchor: .top)
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
