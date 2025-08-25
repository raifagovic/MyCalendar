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
    // ... all properties are unchanged ...
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let date: Date

    @Query private var entries: [DayEntry]
    @State private var selectedPhoto: PhotosPickerItem?
    
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
                if let imageData = entry.backgroundImageData, let uiImage = UIImage(data: imageData) {
                    
                    Text("Frame your image")
                        .font(.headline)
                        .padding(.top)

                    // --- THE NEW, CORRECTED CROPPER ---
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
                    }
                    .frame(width: 300, height: 400) // A fixed frame for the editor
                    .clipped()
                    .gesture(combinedGesture)
                    // Layer 2: A simple, clear overlay to show the crop area
                    .overlay(
                        Rectangle()
                            .stroke(Color.white.opacity(0.8), lineWidth: 2)
                            .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit)
                            .frame(width: 300)
                    )

                    // ... Remove button is unchanged ...
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
                    // ... The "Add Image" UI is unchanged ...
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
                            
                            let editorWidth: CGFloat = 300
                            let editorHeight: CGFloat = 400
                            let scaleX = editorWidth / uiImage.size.width
                            let scaleY = editorHeight / uiImage.size.height
                            let initialScale = max(scaleX, scaleY)
                            
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
            // ... Navigation and other modifiers are unchanged ...
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
