//
//  AddNotificationView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 12. 10. 2025..
//

import SwiftUI
import SwiftData

struct AddNotificationView: View {
    let date: Date // The fixed date for the new notification
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var notificationLabel: String = ""
    @State private var notificationTime: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notification Details") {
                    TextField("Label", text: $notificationLabel)
                    
                    DatePicker("Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                }
                
                Button("Save Notification") {
                    let newNotification = NotificationEntry(date: date, time: notificationTime, label: notificationLabel)
                    modelContext.insert(newNotification)
                    dismiss()
                }
                .disabled(notificationLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .navigationTitle("New Notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
