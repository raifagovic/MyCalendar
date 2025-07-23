//
//  DayDetailView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 23. 7. 2025..
//

import SwiftUI
import PhotosUI // For the photo picker
import SwiftData

struct DayDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let date: Date

    // Find the existing entry for this date or create a new one
    @Query private var entries: [DayEntry]
    private var dayEntry: DayEntry

    init(date: Date) {
        self.date = date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        // This query fetches the specific entry for the selected date
        _entries = Query(filter: #Predicate<DayEntry> { $0.date == startOfDay })
        
        // This part is tricky. Because @Query is initialized before `self` is available,
        // we handle the creation logic inside the view body or through a helper.
        // For simplicity, we'll assume it exists or create it on first action.
        // A more robust solution might use a dedicated ViewModel.
        
        // This is a placeholder initialization. The actual logic is below.
        dayEntry = DayEntry(date: startOfDay)
    }

    // State for Photo Picker
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        // Use the fetched entry if it exists
        let entry = entries.first ?? createAndReturnEntry()
        
        VStack {
            Text("Details for \(date, formatter: DateFormatter.monthAndYear)")
                .font(.largeTitle)
                .padding()

            // --- Your Editing UI Goes Here ---
            
            // Example: Photo Picker
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Label("Add Background Image", systemImage: "photo")
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        entry.backgroundImageData = data
                    }
                }
            }
            
            // Example: Navigation to Drawing View
            NavigationLink("Add/Edit Drawing") {
                // We'll integrate your DailySketchView here next
                Text("Drawing View Placeholder")
            }
            
            // Example: Add Emoticon
            Button("Add ✈️ Emoticon") {
                let newEmoticon = EmoticonInfo(character: "✈️")
                newEmoticon.dayEntry = entry // Link it back to the day
                // You can add a time picker here to set `newEmoticon.time`
                entry.emoticons.append(newEmoticon)
                try? modelContext.save()
            }
            
            Spacer()
        }
    }
    
    // Helper function to create an entry if it doesn't exist.
    private func createAndReturnEntry() -> DayEntry {
        if let existingEntry = entries.first {
            return existingEntry
        } else {
            let newEntry = DayEntry(date: Calendar.current.startOfDay(for: date))
            modelContext.insert(newEntry)
            return newEntry
        }
    }
}
