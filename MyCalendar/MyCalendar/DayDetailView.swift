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
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(currentScale * gestureScale)
                            .offset(
                                x: currentOffset.width + gestureOffset.width,
                                y: currentOffset.height + gestureOffset.height
                            )
                    }
                    .frame(width: 300, height: 400)
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
                            entry.backgroundImageScale = 1.0
                            entry.backgroundImageOffsetX = 0.0
                            entry.backgroundImageOffsetY = 0.0
                        }
                    } label: {
                        Label("Remove Background Image", systemImage: "trash")
                    }
                    .padding()
                    
                } else {
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
                            guard let data = try? await newItem?.loadTransferable(type: Data.self),
                                  let uiImage = UIImage(data: data) else { return }
                            
                            let entryToUpdate: DayEntry
                            if let existingEntry = self.entry {
                                entryToUpdate = existingEntry
                            } else {
                                let newEntry = DayEntry(date: Calendar.current.startOfDay(for: date))
                                modelContext.insert(newEntry)
                                self.entry = newEntry
                                entryToUpdate = newEntry
                            }
                            
                            let editorWidth: CGFloat = 300
                            let editorHeight: CGFloat = 400
                            let scaleX = editorWidth / uiImage.size.width
                            let scaleY = editorHeight / uiImage.size.height
                            let initialScale = max(scaleX, scaleY)
                            
                            withAnimation {
                                entryToUpdate.backgroundImageData = data
                                entryToUpdate.backgroundImageScale = initialScale
                                entryToUpdate.backgroundImageOffsetX = 0
                                entryToUpdate.backgroundImageOffsetY = 0
                                
                                self.currentScale = initialScale
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
        // --- THE DEFINITIVE FIX: Use .task(id:) ---
        // This task will re-run automatically whenever the 'date' changes.
        .task(id: date) {
            await fetchEntry(for: date)
        }
        .onDisappear {
            if let entry = entry {
                entry.backgroundImageScale = self.currentScale
                entry.backgroundImageOffsetX = self.currentOffset.width
                entry.backgroundImageOffsetY = self.currentOffset.height
                try? modelContext.save()
            }
        }
    }
    
    // The fetch function is now async and takes the date as a parameter.
    private func fetchEntry(for date: Date) async {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let predicate = #Predicate<DayEntry> { $0.date == startOfDay }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        do {
            let entries = try modelContext.fetch(descriptor)
            self.entry = entries.first
            
            if let entry = self.entry {
                self.currentScale = entry.backgroundImageScale
                self.currentOffset = CGSize(width: entry.backgroundImageOffsetX, height: entry.backgroundImageOffsetY)
            } else {
                // If no entry is found, reset the state.
                self.currentScale = 1.0
                self.currentOffset = .zero
            }
        } catch {
            print("Failed to fetch entry: \(error)")
        }
    }
}
