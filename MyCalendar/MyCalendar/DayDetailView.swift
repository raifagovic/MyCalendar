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

    @State private var entry: DayEntry?
    @State private var selectedPhoto: PhotosPickerItem?
    
    @State private var currentScale: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureOffset: CGSize = .zero

    var body: some View {
        // ... the body of the view is correct and does not need to change ...
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
                            // We only need the data here.
                            guard let data = try? await newItem?.loadTransferable(type: Data.self) else { return }
                            
                            let entryToUpdate = createOrGetEntry()
                            
                            // --- THE DEFINITIVE FIX FOR THE "TINY DOT" BUG ---
                            withAnimation {
                                // 1. Save the image data.
                                entryToUpdate.backgroundImageData = data
                                
                                // 2. Set the default transform to a clean, un-zoomed state.
                                entryToUpdate.backgroundImageScale = 1.0
                                entryToUpdate.backgroundImageOffsetX = 0
                                entryToUpdate.backgroundImageOffsetY = 0
                                
                                // 3. Update the local state for the editor to match this clean state.
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
            if let entry = entry {
                entry.backgroundImageScale = currentScale
                entry.backgroundImageOffsetX = currentOffset.width
                entry.backgroundImageOffsetY = currentOffset.height
                
                if let croppedData = croppedImageForEntry(entry, frameSize: CGSize(width: 300, height: 400)) {
                    entry.backgroundImageData = croppedData
                    // Reset offsets and scale because now the image is cropped
                    entry.backgroundImageScale = 1.0
                    entry.backgroundImageOffsetX = 0
                    entry.backgroundImageOffsetY = 0
                }
                
                try? modelContext.save()
            }
        }

    }
    
    func croppedImageForEntry(_ entry: DayEntry, frameSize: CGSize) -> Data? {
        guard let data = entry.backgroundImageData,
              let uiImage = UIImage(data: data) else { return nil }
        
        // 1. The size of the frame in the editor (e.g., 300x400)
        let editorSize = CGSize(width: 300, height: 400)
        
        // 2. Scale factor from editor frame to image
        let imageScaleX = uiImage.size.width / editorSize.width
        let imageScaleY = uiImage.size.height / editorSize.height
        
        // 3. Calculate visible rectangle in editor coordinates
        let offsetX = entry.backgroundImageOffsetX
        let offsetY = entry.backgroundImageOffsetY
        let scale = entry.backgroundImageScale
        
        // Inverse transform: what rectangle of the image is visible in the frame?
        let visibleWidth = editorSize.width / scale
        let visibleHeight = editorSize.height / scale
        let originX = (editorSize.width/2 - offsetX)/scale
        let originY = (editorSize.height/2 - offsetY)/scale
        
        let cropRect = CGRect(
            x: originX * imageScaleX,
            y: originY * imageScaleY,
            width: visibleWidth * imageScaleX,
            height: visibleHeight * imageScaleY
        )
        
        // 4. Crop and convert back to Data
        if let cropped = uiImage.cropped(to: cropRect) {
            return cropped.jpegData(compressionQuality: 0.9)
        }
        
        return nil
    }
    
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
                self.currentScale = 1.0
                self.currentOffset = .zero
            }
        } catch {
            print("Failed to fetch entry: \(error)")
        }
    }
    
    // --- We add this simple helper back, as it's needed by the .onChange ---
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
