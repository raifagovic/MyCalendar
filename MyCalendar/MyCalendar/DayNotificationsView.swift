//
//  DayNotificationsView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 12. 10. 2025..
//

import SwiftUI
import SwiftData
//
//struct DayNotificationsView: View {
//    let date: Date
//    @Environment(\.modelContext) private var modelContext
//    
//    @Query private var notifications: [NotificationEntry]
//    
//    @State private var showingAddNotificationSheet = false
//    @State private var notificationToEdit: NotificationEntry? = nil // ✅ Track notification being edited
//    
//    init(date: Date) {
//        self.date = date
//        let calendar = Calendar.current
//        let startOfDay = calendar.startOfDay(for: date)
//        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
//            _notifications = Query(filter: #Predicate<NotificationEntry> { _ in false })
//            return
//        }
//        
//        _notifications = Query(
//            filter: #Predicate<NotificationEntry> { notification in
//                notification.date >= startOfDay && notification.date < endOfDay
//            },
//            sort: \NotificationEntry.time
//        )
//    }
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            Text(date, format: .dateTime.month(.wide).day().year())
//                .font(.headline)
//                .padding(.bottom, 8)
//            
//            if notifications.isEmpty {
//                Text("No notifications for this day.")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .padding(.vertical)
//            } else {
//                List {
//                    ForEach(notifications) { notification in
//                        HStack {
//                            Text(notification.time, format: .dateTime.hour().minute())
//                                .font(.subheadline)
//                            Text(notification.label)
//                                .font(.body)
//                            Spacer()
//                        }
//                        .contentShape(Rectangle()) // ✅ Make entire row tappable
//                        .onTapGesture {
//                            notificationToEdit = notification
//                            showingAddNotificationSheet = true
//                        }
//                    }
//                    .onDelete(perform: deleteNotifications)
//                }
//                .listStyle(.plain)
//            }
//            
//            Button("Add Notification") {
//                notificationToEdit = nil
//                showingAddNotificationSheet = true
//            }
//            .padding(.top, 8)
//        }
//        .padding()
//        .background(Color.black.opacity(0.8))
//        .cornerRadius(15)
//        .shadow(radius: 10)
//        .frame(minWidth: 250, idealWidth: 300, maxWidth: 350)
//        .sheet(isPresented: $showingAddNotificationSheet) {
//            AddNotificationView(
//                date: date,
//                notificationToEdit: notificationToEdit // ✅ Pass notification if editing
//            )
//        }
//    }
//    
//    private func deleteNotifications(at offsets: IndexSet) {
//        for index in offsets {
//            let notification = notifications[index]
//            modelContext.delete(notification)
//            // ✅ Remove scheduled notification from the system
//            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id.uuidString])
//        }
//        try? modelContext.save()
//    }
//}

struct DayNotificationsView: View {
    let date: Date
    @Environment(\.modelContext) private var modelContext
    
    @Query private var notifications: [NotificationEntry]
    
    @State private var notificationToEdit: NotificationEntry? = nil
    
    init(date: Date) {
        self.date = date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            _notifications = Query(filter: #Predicate<NotificationEntry> { _ in false })
            return
        }
        
        _notifications = Query(
            filter: #Predicate<NotificationEntry> { notification in
                notification.date >= startOfDay && notification.date < endOfDay
            },
            sort: \NotificationEntry.time
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
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            notificationToEdit = notification // ✅ Set item directly
                        }
                    }
                    .onDelete(perform: deleteNotifications)
                }
                .listStyle(.plain)
            }
            
            Button("Add Notification") {
                notificationToEdit = NotificationEntry(date: date, time: Date(), label: "")
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(15)
        .shadow(radius: 10)
        .frame(minWidth: 250, idealWidth: 300, maxWidth: 350)
        // ✅ Use sheet(item:) instead of isPresented
        .sheet(item: $notificationToEdit) { notification in
            AddNotificationView(
                date: date,
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
