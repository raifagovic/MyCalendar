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
    
    // --- Gesture State ---
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
                currentScale *= value
            }

        let dragGesture = DragGesture()
            .updating($gestureOffset) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                currentOffset.width += value.translation.width
                currentOffset.height += value.translation.height
            }
        
        let combinedGesture = SimultaneousGesture(magnificationGesture, dragGesture)

        NavigationStack {
            VStack {
                // --- We conditionally show either the editor or the "Add" button ---
                if let imageData = entry.backgroundImageData, let uiImage = UIImage(data: imageData) {
                    
                    // MARK: - Image Editor UI
                    Text("Frame your image")
                        .font(.headline)
                        .padding(.top)

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
                        
                        // Layer 3: The transparent hole
                        Rectangle()
                            .fill(Color.white)
                            .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit)
                            .frame(width: 300)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
                    .frame(height: 400)
                    .clipped()
                    .gesture(combinedGesture)

                    // MARK: - Remove Button (Restored)
                    Button(role: .destructive) {
                        withAnimation {
                            entry.backgroundImageData = nil
                            // Also reset the transform data
                            entry.backgroundImageScale = 1.0
                            entry.backgroundImageOffsetX = 0.0
                            entry.backgroundImageOffsetY = 0.0
                        }
                    } label: {
                        Label("Remove Background Image", systemImage: "trash")
                    }
                    .padding()
                    
                } else {
                    // MARK: - Add Image UI (Restored)
                    Spacer()
                    // The PhotosPicker for adding a new image
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
                            
                            // --- Calculate sensible starting scale ---
                            let editorWidth: CGFloat = 300
                            let editorHeight: CGFloat = 400
                            let scaleX = editorWidth / uiImage.size.width
                            let scaleY = editorHeight / uiImage.size.height
                            let initialScale = max(scaleX, scaleY) // Fill the frame
                            
                            withAnimation {
                                entry.backgroundImageData = data
                                entry.backgroundImageScale = initialScale
                                entry.backgroundImageOffsetX = 0
                                entry.backgroundImageOffsetY = 0
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
        .onAppear {
            self.currentScale = entry.backgroundImageScale
            self.currentOffset = CGSize(width: entry.backgroundImageOffsetX, height: entry.backgroundImageOffsetY)
        }
        .onDisappear {
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
