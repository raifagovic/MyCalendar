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
    
    // Stickers
    @State private var stickers: [StickerInfo] = []
    @State private var selectedSticker: StickerInfo?
    
    // Typing state
    @State private var currentTypingText: String = ""
    @State private var isTyping: Bool = false
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
                GeometryReader { geometry in
                    let canvasSize = geometry.size
                    
                    ZStack {
                        // --- Background ---
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
                        
                        // --- Stickers ---
                        stickersLayer(containerSize: canvasSize)
                        
                        // --- Currently typing sticker (preview only) ---
                        if isTyping && !currentTypingText.isEmpty {
                            Text(currentTypingText)
                                .padding(4)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(Color.accentColor, lineWidth: 1)
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
                        selectedSticker = nil
                        typingFieldFocused = false
                        
                        // Save typing as new sticker
                        if !currentTypingText.isEmpty {
                            let newSticker = StickerInfo(type: .text, content: currentTypingText)
                            stickers.append(newSticker)
                            entry?.stickers.append(newSticker)
                            saveStickerPosition(newSticker, in: canvasSize)
                            try? modelContext.save()
                            
                            currentTypingText = ""
                            isTyping = false
                        }
                    }
                }
                .frame(width: AppConstants.editorPreviewWidth,
                       height: AppConstants.editorPreviewHeight)
                
                // --- Toolbar ---
                HStack(spacing: 40) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 24))
                    }
                    
                    Button {
                        isTyping = true
                        typingFieldFocused = true
                    } label: {
                        Image(systemName: "keyboard")
                            .font(.system(size: 24))
                    }
                    
                    Button {
                        // TODO: implement drawing tools
                    } label: {
                        Image(systemName: "pencil.tip")
                            .font(.system(size: 24))
                    }
                    
                    Button(role: .destructive) {
                        if let entry = entry {
                            withAnimation {
                                entry.backgroundImageData = nil
                                entry.backgroundImageScale = 1.0
                                entry.backgroundImageOffsetX = 0
                                entry.backgroundImageOffsetY = 0
                            }
                        }
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 24))
                    }
                }
                .padding(.top, 8)
                
                // --- Hidden TextField ---
                TextField("", text: $currentTypingText)
                    .focused($typingFieldFocused)
                    .frame(width: 0, height: 0)
                    .opacity(0.01)
                    .onChange(of: currentTypingText) {
                        isTyping = true
                    }
            }
            .navigationTitle("Edit Day")
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
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func stickersLayer(containerSize: CGSize) -> some View {
        ForEach($stickers) { $sticker in
            StickerView(
                sticker: $sticker,
                isSelected: Binding(
                    get: { selectedSticker?.id == sticker.id },
                    set: { isSelected in
                        selectedSticker = isSelected ? sticker : nil
                    }
                ),
                containerSize: containerSize // ✅ Pass container size
            )
            .onChange(of: sticker.posX) { _ in saveStickerPosition(sticker, in: containerSize) }
            .onChange(of: sticker.posY) { _ in saveStickerPosition(sticker, in: containerSize) }
            .onChange(of: sticker.scale) { _ in saveStickerPosition(sticker, in: containerSize) }
        }
    }
    
    private func saveStickerPosition(_ sticker: StickerInfo, in containerSize: CGSize) {
        sticker.relativePosX = (sticker.posX + containerSize.width / 2) / containerSize.width
        sticker.relativePosY = (sticker.posY + containerSize.height / 2) / containerSize.height
        try? modelContext.save()
    }
    
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
}






