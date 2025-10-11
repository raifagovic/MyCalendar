//
//  DayNotificationsView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 12. 10. 2025..
//

import SwiftUI
import SwiftData

struct DayNotificationsView: View {
    let date: Date // The date for which we are showing notifications
    @Environment(\.modelContext) private var modelContext
    
    @Query private var notifications: [NotificationEntry]
    
    @State private var showingAddNotificationSheet = false
    
    init(date: Date) {
        self.date = date
        // Filter notifications for the specific date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            _notifications = Query(filter: #Predicate<NotificationEntry> { _ in false }) // Should not happen
            return
        }
        
        _notifications = Query(
            filter: #Predicate<NotificationEntry> { notification in
                notification.date >= startOfDay && notification.date < endOfDay
            },
            sort: \NotificationEntry.time // Sort by time
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
                        }
                    }
                    .onDelete(perform: deleteNotifications)
                }
                .listStyle(.plain)
            }
            
            Button("Add Notification") {
                showingAddNotificationSheet = true
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.black.opacity(0.8)) // Darker background
        .cornerRadius(15)
        .shadow(radius: 10)
        .frame(minWidth: 250, idealWidth: 300, maxWidth: 350)
        .sheet(isPresented: $showingAddNotificationSheet) {
            AddNotificationView(date: date)
        }
    }
    
    private func deleteNotifications(at offsets: IndexSet) {
        for index in offsets {
            let notification = notifications[index]
            modelContext.delete(notification)
        }
    }
}
