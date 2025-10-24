//
//  DayNotificationsView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 12. 10. 2025..
//

import SwiftUI
import SwiftData

struct DayNotificationsView: View {
    // This `date` is the one passed to the View from its parent (e.g., CalendarView).
    // It is kept as a `let` constant, as it represents the specific day this view is for.
    let date: Date
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var notifications: [NotificationEntry]
    
    @State private var notificationToEdit: NotificationEntry? = nil
    
    // ✅ Custom initializer for DayNotificationsView
    init(date: Date) {
        // IMPORTANT: Initialize the `date` property FIRST.
        // It's crucial for `let` properties in an init if there's a parameter with the same name.
        self.date = date // Assign the incoming parameter to the `self.date` property.

        // Then, derive the `startOfDay` from `self.date` for use in the Query filter.
        // This *local constant* `startOfDayForQuery` is what the `@Predicate` will use.
        // This is safe because `self.date` is already initialized.
        let startOfDayForQuery = Calendar.current.startOfDay(for: self.date)
        
        // Now, the @Query can safely use `startOfDayForQuery` for a direct equality comparison.
        // SwiftData's predicate system is happy with a simple `Date` constant.
        _notifications = Query(
            filter: #Predicate<NotificationEntry> { notification in
                notification.date == startOfDayForQuery // ✅ Use the local `startOfDayForQuery` constant
            },
            sort: \NotificationEntry.time
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            // Display the date. Since `NotificationEntry.init` normalizes the date,
            // we should probably display `self.date` which might not be `startOfDay`
            // if passed directly from CalendarView. Or, if DayNotificationsView is
            // always intended to display a start-of-day date, we can re-normalize for display.
            // For now, `self.date` is fine for display, as NotificationEntry's internal
            // date will always be startOfDay.
            Text(date, format: .dateTime.month(.wide).day().year())
                .font(.headline)
                .padding(.bottom, 8)
            
            if notifications.isEmpty {
                Text("No notifications for this day.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.vertical)
            } else {
                List {
                    ForEach(notifications) { notification in
                        HStack {
                            Text(notification.time, format: .dateTime.hour().minute())
                                .font(.subheadline)
                            Text(notification.label)
                                .font(.body)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            notificationToEdit = notification
                        }
                    }
                    .onDelete(perform: deleteNotifications)
                }
                .listStyle(.plain)
            }
            
            Button("Add Notification") {
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: date)

                // Create managed NotificationEntry and insert it into the model context
                let newEntry = NotificationEntry(date: startOfDay, time: Date(), label: "")
                modelContext.insert(newEntry)

                // Show the sheet for editing the newly inserted entry
                notificationToEdit = newEntry
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(15)
        .shadow(radius: 10)
        .frame(minWidth: 250, idealWidth: 300, maxWidth: 350)
        .sheet(item: $notificationToEdit) { notification in
            AddNotificationView(
                date: self.date, // Pass `self.date` to AddNotificationView
                notificationToEdit: notification
            )
        }
    }
    
    private func deleteNotifications(at offsets: IndexSet) {
        for index in offsets {
            let notification = notifications[index]
            modelContext.delete(notification)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id.uuidString])
        }
        try? modelContext.save()
    }
}
