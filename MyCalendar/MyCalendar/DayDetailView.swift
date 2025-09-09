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
    
    // Background image transform state
    @State private var currentScale: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureOffset: CGSize = .zero
    
    // Stickers (both text and emoji)
    @State private var stickers: [StickerInfo] = []
    
    // Typing state
    @State private var currentTypingText: String = ""
    @State private var isTyping: Bool = false
    @State private var selectedSticker: StickerInfo?
    @FocusState private var typingFieldFocused: Bool
    
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
                // --- Main canvas ---
                ZStack {
                    if let entry = entry,
                       let imageData = entry.backgroundImageData,
                       let uiImage = UIImage(data: imageData) {
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(currentScale * gestureScale)
                            .offset(
                                x: currentOffset.width + gestureOffset.width,
                                y: currentOffset.height + gestureOffset.height
                            )
                            .clipped()
                            .gesture(combinedGesture)
                        
                    } else {
                        Rectangle()
                            .fill(Color.black.opacity(0.1))
                    }
                    
                    // Render all stickers
                    ForEach($stickers) { $sticker in
                        StickerView(
                            sticker: $sticker,
                            isSelected: Binding(
                                get: { selectedSticker?.id == sticker.id },
                                set: { isSelected in
                                    selectedSticker = isSelected ? sticker : nil
                                }
                            )
                        )
                    }
                    
                    // Currently typing text sticker
                    if isTyping && !currentTypingText.isEmpty {
                        StickerView(
                            sticker: .constant(
                                StickerInfo(type: .text, content: currentTypingText)
                            ),
                            isSelected: .constant(true)
                        )
                    }
                }
                .frame(width: AppConstants.editorPreviewWidth,
                       height: AppConstants.editorPreviewHeight)
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.8), lineWidth: 2)
                )
                .onTapGesture {
                    // Deselect stickers + dismiss keyboard
                    selectedSticker = nil
                    typingFieldFocused = false
                    
                    // Save current typing as a sticker
                    saveCurrentTyping()
                }
                
                // --- Toolbar ---
                HStack(spacing: 40) {
                    // Background image picker
                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 24))
                    }
                    
                    // Keyboard icon
                    Button {
                        isTyping = true
                        typingFieldFocused = true
                    } label: {
                        Image(systemName: "keyboard")
                            .font(.system(size: 24))
                    }
                    
                    // Pencil (drawing placeholder)
                    Button {
                        // TODO: implement drawing tools
                    } label: {
                        Image(systemName: "pencil.tip")
                            .font(.system(size: 24))
                    }
                    
                    // Recycle bin
                    Button(role: .destructive) {
                        if let entry = entry {
                            withAnimation {
                                entry.backgroundImageData = nil
                                entry.backgroundImageScale = 1.0
                                entry.backgroundImageOffsetX = 0
                                entry.backgroundImageOffsetY = 0
                                try? modelContext.save()
                            }
                        }
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 24))
                    }
                }
                .padding(.top, 8)
                
                // Hidden TextField for keyboard input
                TextField("", text: $currentTypingText)
                    .focused($typingFieldFocused)
                    .frame(width: 0, height: 0)
                    .opacity(0.01)
                    .onChange(of: currentTypingText) { _ in
                        isTyping = true
                    }
            }
            .navigationTitle("Edit Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveCurrentTyping()
                        dismiss()
                    }
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
                try? modelContext.save()
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                guard let data = try? await newItem?.loadTransferable(type: Data.self) else { return }
                let entryToUpdate = createOrGetEntry()
                withAnimation {
                    entryToUpdate.backgroundImageData = data
                    entryToUpdate.backgroundImageScale = 1.0
                    entryToUpdate.backgroundImageOffsetX = 0
                    entryToUpdate.backgroundImageOffsetY = 0
                    self.currentScale = 1.0
                    self.currentOffset = .zero
                    try? modelContext.save()
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func fetchEntry(for date: Date) async {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let predicate = #Predicate<DayEntry> { $0.date == startOfDay }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        do {
            let entries = try modelContext.fetch(descriptor)
            self.entry = entries.first
            
            if let entry = self.entry {
                self.stickers = entry.stickers
                self.currentScale = entry.backgroundImageScale
                self.currentOffset = CGSize(width: entry.backgroundImageOffsetX,
                                            height: entry.backgroundImageOffsetY)
            } else {
                self.currentScale = 1.0
                self.currentOffset = .zero
            }
        } catch {
            print("Failed to fetch entry: \(error)")
        }
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
    
    private func saveCurrentTyping() {
        guard !currentTypingText.isEmpty else { return }
        let newSticker = StickerInfo(
            type: .text,
            content: currentTypingText
        )
        modelContext.insert(newSticker)
        entry?.stickers.append(newSticker)
        stickers.append(newSticker)
        try? modelContext.save()
        currentTypingText = ""
        isTyping = false
    }
}


