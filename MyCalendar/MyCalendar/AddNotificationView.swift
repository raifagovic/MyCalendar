//
//  AddNotificationView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 12. 10. 2025..
//

import SwiftUI
import SwiftData

struct AddNotificationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let date: Date // The date for which to add a notification
    
    @State private var notificationTime: Date = Date()
    @State private var notificationLabel: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                TextField("Label", text: $notificationLabel)
            }
            .navigationTitle("Add Notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
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
        let newNotification = NotificationEntry(date: Calendar.current.startOfDay(for: date), time: notificationTime, label: notificationLabel)
        modelContext.insert(newNotification)
        
        // ✅ Explicitly save changes after insertion
        try? modelContext.save()
    }
}
