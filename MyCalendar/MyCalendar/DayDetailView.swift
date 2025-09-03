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
    @State private var showingEmojiPicker = false
    @State private var newEmoji: String = ""
    
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
                    .frame(width: AppConstants.editorPreviewWidth,
                           height: AppConstants.editorPreviewHeight)   // ✅ same ratio as month cells
                    .clipped()
                    .gesture(combinedGesture)
                    .overlay(
                        Rectangle()
                            .stroke(Color.white.opacity(0.8), lineWidth: 2) // ✅ matches the container size
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
                    
                    // NEW: Add Emoticon button
                    Button {
                        showingEmojiPicker = true
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: "face.smiling")
                                .font(.system(size: 50))
                            Text("Add Emoticon")
                                .font(.headline)
                        }
                        .foregroundColor(.accentColor)
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
                entry.backgroundImageScale = self.currentScale
                entry.backgroundImageOffsetX = self.currentOffset.width
                entry.backgroundImageOffsetY = self.currentOffset.height
                try? modelContext.save()
            }
        }
        .sheet(isPresented: $showingEmojiPicker) {
            VStack(spacing: 20) {
                Text("Pick an Emoji")
                    .font(.headline)
                
                TextField("😀", text: $newEmoji)
                    .font(.system(size: 40))
                    .multilineTextAlignment(.center)
                    .onSubmit {
                        saveEmoji()
                    }
                    .padding()
                    .frame(width: 80)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button("Save") {
                    saveEmoji()
                }
                .disabled(newEmoji.isEmpty)
            }
            .padding()
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
    
    private func saveEmoji() {
        guard !newEmoji.isEmpty else { return }
        let entryToUpdate = createOrGetEntry()
        let emoji = EmoticonInfo(character: newEmoji, time: Date())
        entryToUpdate.emoticons.append(emoji)
        try? modelContext.save()
        newEmoji = ""
        showingEmojiPicker = false
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
