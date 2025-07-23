//
//  ContentView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 3. 7. 2025..
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        // We will build this out with more features, but for now,
        // it just displays the calendar as the main screen.
        CalendarView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: DayEntry.self, inMemory: true)
}
