//
//  DayDetailView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 23. 7. 2025..
//

import SwiftUI
import PhotosUI
import SwiftData

struct DayDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let date: Date

    @Query private var entries: [DayEntry]
    @State private var selectedPhoto: PhotosPickerItem?

    init(date: Date) {
        self.date = date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        _entries = Query(filter: #Predicate<DayEntry> { $0.date == startOfDay })
    }

    var body: some View {
        let entry = entries.first ?? createAndReturnEntry()
        
        VStack {
            Text("Details for \(date, formatter: DateFormatter.monthAndYear)")
                .font(.largeTitle)
                .padding()

            // --- THIS IS THE UPDATED BACKGROUND IMAGE SECTION ---

            if let imageData = entry.backgroundImageData, let uiImage = UIImage(data: imageData) {
                // An image EXISTS, so show a preview and a Remove button.
                VStack {
                    Text("Current Background:")
                        .font(.headline)
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150) // Show a reasonably sized preview
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                    
                    // The "Remove" button
                    Button(role: .destructive) { // .destructive gives it a red color (on iOS)
                        withAnimation {
                            entry.backgroundImageData = nil
                        }
                    } label: {
                        Label("Remove Background Image", systemImage: "trash")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)

            } else {
                // NO image exists, so show the PhotosPicker to add one.
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("Add Background Image", systemImage: "photo")
                }
                .onChange(of: selectedPhoto) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            withAnimation {
                                entry.backgroundImageData = data
                            }
                        }
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
        .padding()
    }
    
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
