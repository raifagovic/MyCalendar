//
//  MyCalendarApp.swift
//  MyCalendar
//
//  Created by Raif Agovic on 3. 7. 2025..
//

import SwiftUI
import SwiftData

@main
struct MyCalendarApp: App {
    var sharedModelContainer: ModelContainer = {
        // --- THIS IS THE CORRECTED LINE ---
        let schema = Schema([
            DayEntry.self,
            EmoticonInfo.self // Add EmoticonInfo here
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
