//
//  AddNotificationView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 12. 10. 2025..
//

//import SwiftUI
//import SwiftData
//import UserNotifications
//
//struct AddNotificationView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Environment(\.dismiss) private var dismiss
//    
//    let date: Date // The date for which to add a notification
//    
//    @State private var notificationTime: Date = Date()
//    @State private var notificationLabel: String = ""
//    
//    var body: some View {
//        NavigationStack {
//            Form {
//                DatePicker("Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
//                TextField("Label", text: $notificationLabel)
//            }
//            .navigationTitle("Add Notification")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Save") {
//                        saveNotification()
//                        dismiss()
//                    }
//                    .disabled(notificationLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
//                }
//            }
//        }
//    }
//    
//    private func saveNotification() {
//        let startOfDay = Calendar.current.startOfDay(for: date)
//        let newNotification = NotificationEntry(date: startOfDay, time: notificationTime, label: notificationLabel)
//        modelContext.insert(newNotification)
//        try? modelContext.save()
//
//        // Schedule a real local notification
//        scheduleLocalNotification(for: newNotification)
//    }
//
//    private func scheduleLocalNotification(for entry: NotificationEntry) {
//        let content = UNMutableNotificationContent()
//        content.title = "Reminder"
//        content.body = entry.label
//        content.sound = .default
//
//        // Combine the entry.date (day) and entry.time (hour/minute)
//        var calendar = Calendar.current
//        var components = calendar.dateComponents([.year, .month, .day], from: entry.date)
//        let timeComponents = calendar.dateComponents([.hour, .minute], from: entry.time)
//        components.hour = timeComponents.hour
//        components.minute = timeComponents.minute
//
//        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
//
//        let request = UNNotificationRequest(
//            identifier: entry.id.uuidString,
//            content: content,
//            trigger: trigger
//        )
//
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("❌ Failed to schedule notification: \(error.localizedDescription)")
//            } else {
//                print("✅ Notification scheduled for \(components)")
//            }
//        }
//    }
//}

import SwiftUI
import SwiftData
import UserNotifications

struct AddNotificationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let date: Date // The date for which to add/edit a notification
    var notificationToEdit: NotificationEntry? = nil // ✅ Optional for editing
    
    @State private var notificationTime: Date
    @State private var notificationLabel: String
    
    init(date: Date, notificationToEdit: NotificationEntry? = nil) {
        self.date = date
        self.notificationToEdit = notificationToEdit
        
        // Initialize state from existing notification if editing
        _notificationTime = State(initialValue: notificationToEdit?.time ?? Date())
        _notificationLabel = State(initialValue: notificationToEdit?.label ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                TextField("Label", text: $notificationLabel)
            }
            .navigationTitle(notificationToEdit == nil ? "Add Notification" : "Edit Notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNotification()
                        dismiss()
                    }
                    .disabled(notificationLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveNotification() {
        if let entry = notificationToEdit {
            // ✅ Editing existing notification
            entry.time = notificationTime
            entry.label = notificationLabel
            
            // Reschedule the local notification
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [entry.id.uuidString])
            scheduleLocalNotification(for: entry)
            
        } else {
            // ✅ Adding new notification
            let startOfDay = Calendar.current.startOfDay(for: date)
            let newEntry = NotificationEntry(date: startOfDay, time: notificationTime, label: notificationLabel)
            modelContext.insert(newEntry)
            
            scheduleLocalNotification(for: newEntry)
        }
        
        try? modelContext.save()
    }

    private func scheduleLocalNotification(for entry: NotificationEntry) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = entry.label
        content.sound = .default

        // Combine the entry.date (day) and entry.time (hour/minute)
        var calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: entry.date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: entry.time)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: entry.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled for \(components)")
            }
        }
    }
}
