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
    
    @State private var currentScale: CGFloat = 1.0
    @State private var currentOffsetX: CGFloat = 0.0
    @State private var currentOffsetY: CGFloat = 0.0

    init(date: Date) {
        self.date = date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        _entries = Query(filter: #Predicate<DayEntry> { $0.date == startOfDay })
    }

    var body: some View {
            let entry = entries.first ?? createAndReturnEntry()

            NavigationStack {
                VStack(spacing: 0) {
                    if let imageData = entry.backgroundImageData {
                        // --- THE NEW WYSIWYG CROPPER UI ---
                        GeometryReader { geometry in
                            let viewportWidth = geometry.size.width * 0.9 // Use 90% of screen width
                            let viewportHeight = viewportWidth / AppConstants.calendarCellAspectRatio

                            ZStack {
                                // Layer 1: The movable image
                                ImageCropperView(
                                    imageData: imageData,
                                    scale: $currentScale,
                                    offsetX: $currentOffsetX,
                                    offsetY: $currentOffsetY
                                )

                                // Layer 2: The darkening overlay
                                Rectangle()
                                    .fill(.black.opacity(0.6))

                                // Layer 3: The "clear" viewport that punches a hole
                                Rectangle()
                                    .frame(width: viewportWidth, height: viewportHeight)
                                    .blendMode(.destinationOut)
                            }
                            .compositingGroup() // Essential for blendMode to work correctly
                            .clipped() // Clip the whole ZStack to its bounds
                        }
                        .padding(.vertical)

                        // --- Action Buttons ---
                        VStack {
                            Text("Pan and pinch to frame your image")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button(role: .destructive) {
                                withAnimation {
                                    entry.backgroundImageData = nil
                                    entry.backgroundImageScale = 1.0
                                    entry.backgroundImageOffsetX = 0
                                    entry.backgroundImageOffsetY = 0
                                }
                            } label: {
                                Label("Remove Background Image", systemImage: "trash")
                            }
                            .padding(.top)
                        }
                        .padding(.horizontal)

                    } else {
                        // Placeholder for when no image is selected
                        Spacer()
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Label("Add Background Image", systemImage: "photo")
                        }
                        .onChange(of: selectedPhoto) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    withAnimation { entry.backgroundImageData = data }
                                }
                            }
                        }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground)) // A neutral background
                .navigationTitle("Frame Your Image")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            // The onDisappear modifier will handle the actual saving
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                currentScale = entry.backgroundImageScale
                currentOffsetX = entry.backgroundImageOffsetX
                currentOffsetY = entry.backgroundImageOffsetY
            }
            .onDisappear {
                entry.backgroundImageScale = currentScale
                entry.backgroundImageOffsetX = currentOffsetX
                entry.backgroundImageOffsetY = currentOffsetY
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
