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

    @State private var entry: DayEntry?
    @State private var selectedPhoto: PhotosPickerItem?
    
    // --- We use the direct gesture state ---
    @State private var currentScale: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureOffset: CGSize = .zero

    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .updating($gestureScale) { value, state, _ in state = value }
            .onEnded { value in currentScale *= value }

        let dragGesture = DragGesture()
            .updating($gestureOffset) { value, state, _ in state = value.translation }
            .onEnded { value in
                currentOffset.width += value.translation.width
                currentOffset.height += value.translation.height
            }
        
        let combinedGesture = SimultaneousGesture(magnificationGesture, dragGesture)

        NavigationStack {
            VStack {
                if let entry = entry, let imageData = entry.backgroundImageData, let uiImage = UIImage(data: imageData) {
                    
                    Text("Frame your image")
                        .font(.headline)
                        .padding(.top)

                    ZStack {
                        // The interactive image
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill() // .scaledToFill() is the key for a good starting point
                            .scaleEffect(currentScale * gestureScale)
                            .offset(
                                x: currentOffset.width + gestureOffset.width,
                                y: currentOffset.height + gestureOffset.height
                            )
                    }
                    .frame(width: 300, height: 400) // A fixed frame for the editor
                    .clipped()
                    .gesture(combinedGesture)
                    .overlay(
                        Rectangle()
                            .stroke(Color.white.opacity(0.8), lineWidth: 2)
                            .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit)
                            .frame(width: 300)
                    )

                    Button(role: .destructive) {
                        withAnimation {
                            entry.backgroundImageData = nil
                            // Reset the transform data
                            entry.backgroundImageScale = 1.0
                            entry.backgroundImageOffsetX = 0.0
                            entry.backgroundImageOffsetY = 0.0
                        }
                    } label: { Label("Remove Background Image", systemImage: "trash") }
                    .padding()
                    
                } else {
                    // ... The "Add Image" UI ...
                    Spacer()
                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                        VStack(spacing: 10) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 50))
                            Text("Add Background Image")
                                .font(.headline)
                        }
                        .foregroundColor(.accentColor)
                    }
                    .onChange(of: selectedPhoto) { _, newItem in
                        Task {
                            guard let data = try? await newItem?.loadTransferable(type: Data.self) else { return }
                            
                            let entryToUpdate = createOrGetEntry()
                            
                            withAnimation {
                                entryToUpdate.backgroundImageData = data
                                // Reset to a default state
                                entryToUpdate.backgroundImageScale = 1.0
                                entryToUpdate.backgroundImageOffsetX = 0
                                entryToUpdate.backgroundImageOffsetY = 0
                                
                                // Update our local state to match
                                self.currentScale = 1.0
                                self.currentOffset = .zero
                            }
                        }
                    }
                    Spacer()
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
        .task(id: date) {
            await fetchEntry(for: date)
        }
        .onDisappear {
            // We save the raw scale and offset values.
            if let entry = entry {
                entry.backgroundImageScale = self.currentScale
                entry.backgroundImageOffsetX = self.currentOffset.width
                entry.backgroundImageOffsetY = self.currentOffset.height
                try? modelContext.save()
            }
        }
    }
    
    private func fetchEntry(for date: Date) async {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let predicate = #Predicate<DayEntry> { $0.date == startOfDay }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        do {
            let entries = try modelContext.fetch(descriptor)
            self.entry = entries.first
            
            if let entry = self.entry {
                // When we fetch, we load the saved values into our local state.
                self.currentScale = entry.backgroundImageScale
                self.currentOffset = CGSize(width: entry.backgroundImageOffsetX, height: entry.backgroundImageOffsetY)
            } else {
                self.currentScale = 1.0
                self.currentOffset = .zero
            }
        } catch { print("Failed to fetch entry: \(error)") }
    }
    
    private func createOrGetEntry() -> DayEntry {
        if let existingEntry = self.entry {
            return existingEntry
        } else {
            let newEntry = DayEntry(date: Calendar.current.startOfDay(for: date))
            modelContext.insert(newEntry)
            self.entry = newEntry
            return newEntry
        }
    }
}
