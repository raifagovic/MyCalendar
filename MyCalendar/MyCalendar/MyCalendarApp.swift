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
    init() {
        // Ask user for permission to send notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else {
                print("Notifications permission granted: \(success)")
            }
        }
    }
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DayEntry.self,
            StickerInfo.self, // ✅ Use StickerInfo instead of EmoticonInfo
            NotificationEntry.self
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
