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
    @Environment(\.dismiss) private var dismiss
    let date: Date

    @Query private var entries: [DayEntry]
    @State private var selectedPhoto: PhotosPickerItem?
    
    // --- Gesture State is now managed directly in this view ---
    @State private var currentScale: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero

    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureOffset: CGSize = .zero

    init(date: Date) {
        self.date = date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        _entries = Query(filter: #Predicate<DayEntry> { $0.date == startOfDay })
    }

    var body: some View {
        let entry = entries.first ?? createAndReturnEntry()

        // --- Gesture Definitions ---
        let magnificationGesture = MagnificationGesture()
            .updating($gestureScale) { value, state, _ in
                state = value
            }
            .onEnded { value in
                // Add the gesture's change to the final scale
                currentScale *= value
            }

        let dragGesture = DragGesture()
            .updating($gestureOffset) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                // Add the gesture's translation to the final offset
                currentOffset.width += value.translation.width
                currentOffset.height += value.translation.height
            }
        
        let combinedGesture = SimultaneousGesture(magnificationGesture, dragGesture)

        NavigationStack {
            VStack {
                if let imageData = entry.backgroundImageData, let uiImage = UIImage(data: imageData) {
                    
                    Text("Frame your image")
                        .font(.headline)
                        .padding(.top)

                    // --- The New, Contained, "WhatsApp Style" Editor ---
                    ZStack {
                        // Layer 1: The interactive image
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(currentScale * gestureScale)
                            .offset(
                                x: currentOffset.width + gestureOffset.width,
                                y: currentOffset.height + gestureOffset.height
                            )
                        
                        // Layer 2: The dimming overlay
                        Rectangle()
                            .fill(.black.opacity(0.4))
                        
                        // Layer 3: The transparent hole, created with a mask
                        Rectangle()
                            .fill(Color.white) // This color doesn't matter, it's just for the shape
                            .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit)
                            .frame(width: 300) // Give the hole a fixed, aesthetic width
                            .blendMode(.destinationOut) // This cuts the hole
                    }
                    .compositingGroup() // Crucial for blendMode to work correctly
                    .frame(height: 400) // A fixed, reasonable height for the whole editor
                    .clipped() // CRUCIAL: Contains the image and stops it from spilling
                    .gesture(combinedGesture) // Apply gestures to the entire editor frame

                    // ... Remove Button and other UI ...
                    Button(role: .destructive) { /* ... remove logic ... */ } label: { /* ... label ... */ }
                    .padding()
                    
                } else {
                    // ... PhotosPicker UI ...
                }
            }
            .navigationTitle("Frame Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            // Load the saved values
            self.currentScale = entry.backgroundImageScale
            self.currentOffset = CGSize(width: entry.backgroundImageOffsetX, height: entry.backgroundImageOffsetY)
        }
        .onDisappear {
            // Save the final values
            entry.backgroundImageScale = self.currentScale
            entry.backgroundImageOffsetX = self.currentOffset.width
            entry.backgroundImageOffsetY = self.currentOffset.height
            try? modelContext.save()
        }
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
