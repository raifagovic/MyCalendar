////
////  DayDetailView.swift
////  MyCalendar
////
////  Created by Raif Agovic on 23. 7. 2025..
////
//
//import SwiftUI
//import PhotosUI
//import SwiftData
//
//struct DayDetailView: View {
//    // ... all properties are unchanged ...
//    @Environment(\.modelContext) private var modelContext
//    @Environment(\.dismiss) private var dismiss
//
//    let date: Date
//
//    @State private var entry: DayEntry?
//    @State private var selectedPhoto: PhotosPickerItem?
//
//    @State private var currentScale: CGFloat = 1.0
//    @State private var currentOffset: CGSize = .zero
//    
//    // Background image gesture states
//    @GestureState private var backgroundGestureScale: CGFloat = 1.0
//    @GestureState private var backgroundGestureOffset: CGSize = .zero
//
//    @State private var selectedStickerID: UUID?
//    
//    // Sticker gesture states (unified)
//    @State private var initialStickerState: (pos: CGPoint, scale: CGFloat, rot: Double)?
//    @GestureState private var stickerGestureScale: CGFloat = 1.0
//    @GestureState private var stickerGestureOffset: CGSize = .zero
//    @GestureState private var stickerGestureRotation: Angle = .zero
//
//
//    @State private var currentTypingText: String = ""
//    @State private var isTyping: Bool = false
//    @FocusState private var typingFieldFocused: Bool
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                editorView
//                toolbarView
//                hiddenTextField
//            }
//            .navigationTitle("Edit Day")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar { toolbarDoneButton }
//        }
//        .task(id: date) { await fetchEntry(for: date) }
//        .onDisappear { saveBackgroundState() }
//        .onChange(of: selectedPhoto) { _, newItem in loadPhoto(newItem) }
//    }
//}
//
//// MARK: - Subviews
//private extension DayDetailView {
//
//    var editorView: some View {
//        GeometryReader { geometry in
//            let canvasSize = geometry.size
//            ZStack {
//                backgroundImageView(canvasSize: canvasSize)
//                stickersLayer(containerSize: canvasSize)
//                typingPreview
//                
//                // --- THE REVISED FIX: A Single Unified Gesture Overlay ---
//                Rectangle()
//                    .fill(Color.white.opacity(0.01)) // Invisible touch area
//                    .contentShape(Rectangle()) // Essential for gestures on clear views
//                    .gesture(
//                        SimultaneousGesture(
//                            SimultaneousGesture(
//                                DragGesture(minimumDistance: 0) // Minimum distance 0 to detect taps
//                                    .updating($stickerGestureOffset) { value, state, _ in state = value.translation }
//                                    .updating($backgroundGestureOffset) { value, state, _ in state = value.translation }
//                                    .onChanged { value in
//                                        handleUnifiedDragChange(value, canvasSize: canvasSize)
//                                    }
//                                    .onEnded { value in
//                                        handleUnifiedDragEnd(value, canvasSize: canvasSize)
//                                    },
//                                MagnificationGesture()
//                                    .updating($stickerGestureScale) { value, state, _ in state = value }
//                                    .updating($backgroundGestureScale) { value, state, _ in state = value }
//                                    .onChanged { value in
//                                        handleUnifiedScaleChange(value, canvasSize: canvasSize)
//                                    }
//                                    .onEnded { value in
//                                        handleUnifiedScaleEnd(value, canvasSize: canvasSize)
//                                    }
//                            ),
//                            RotationGesture()
//                                .updating($stickerGestureRotation) { value, state, _ in state = value }
//                                .onChanged { value in
//                                    handleUnifiedRotationChange(value, canvasSize: canvasSize)
//                                }
//                                .onEnded { value in
//                                    handleUnifiedRotationEnd(value, canvasSize: canvasSize)
//                                }
//                        )
//                    )
//            }
//            .frame(width: AppConstants.editorPreviewWidth,
//                   height: AppConstants.editorPreviewHeight)
//            .overlay(Rectangle().stroke(Color.white.opacity(0.8), lineWidth: 2))
//        }
//        .frame(width: AppConstants.editorPreviewWidth,
//               height: AppConstants.editorPreviewHeight)
//    }
//
//    // ... other subviews are correct ...
//    var toolbarView: some View {
//        HStack(spacing: 40) {
//            PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
//                Image(systemName: "photo.on.rectangle.angled")
//                    .font(.system(size: 24))
//            }
//
//            Button {
//                isTyping = true
//                typingFieldFocused = true
//            } label: {
//                Image(systemName: "keyboard")
//                    .font(.system(size: 24))
//            }
//
//            Button {
//                // Placeholder for future drawing tools
//            } label: {
//                Image(systemName: "pencil.tip")
//                    .font(.system(size: 24))
//            }
//
//            Button(role: .destructive) {
//                if let entry = entry {
//                    withAnimation {
//                        entry.backgroundImageData = nil
//                        entry.backgroundImageScale = 1.0
//                        entry.backgroundImageOffsetX = 0
//                        entry.backgroundImageOffsetY = 0
//                    }
//                    try? modelContext.save()
//                }
//            } label: {
//                Image(systemName: "trash")
//                    .font(.system(size: 24))
//            }
//        }
//        .padding(.top, 8)
//    }
//
//    var hiddenTextField: some View {
//        TextField("", text: $currentTypingText)
//            .focused($typingFieldFocused)
//            .frame(width: 0, height: 0)
//            .opacity(0.01)
//            .onChange(of: currentTypingText) { isTyping = true }
//    }
//
//    var toolbarDoneButton: some ToolbarContent {
//        ToolbarItem(placement: .confirmationAction) {
//            Button("Done") {
//                commitTypingIfNeeded(containerSize: CGSize(width: AppConstants.editorPreviewWidth,
//                                                           height: AppConstants.editorPreviewHeight))
//                dismiss()
//            }
//        }
//    }
//
//    var typingPreview: some View {
//        Group {
//            if isTyping && !currentTypingText.isEmpty {
//                Text(currentTypingText)
//                    .padding(4)
//                    .background(Color.clear)
//                    .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous)
//                                .stroke(Color.accentColor, lineWidth: 1))
//            }
//        }
//    }
//    
//    func backgroundImageView(canvasSize: CGSize) -> some View {
//        Group {
//            if let entry = entry,
//               let imageData = entry.backgroundImageData,
//               let uiImage = UIImage(data: imageData) {
//
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .scaledToFill()
//                    .scaleEffect(currentScale * backgroundGestureScale) // Apply current gesture state
//                    .offset(x: currentOffset.width + backgroundGestureOffset.width, // Apply current gesture state
//                            y: currentOffset.height + backgroundGestureOffset.height)
//                    .clipped()
//            } else {
//                Rectangle()
//                    .fill(Color.black.opacity(0.1))
//            }
//        }
//    }
//
//
//    func stickersLayer(containerSize: CGSize) -> some View {
//        Group {
//            if let entry = entry {
//                ForEach(entry.stickers) { sticker in
//                    StickerView(
//                        sticker: sticker,
//                        containerSize: containerSize,
//                        isSelected: selectedStickerID == sticker.id
//                    )
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Gestures
//private extension DayDetailView {
//    // --- REVISED, CENTRALIZED GESTURE HANDLING LOGIC ---
//
//    func handleUnifiedDragChange(_ value: DragGesture.Value, canvasSize: CGSize) {
//        if let selectedStickerID = selectedStickerID,
//           let index = entry?.stickers.firstIndex(where: { $0.id == selectedStickerID }) {
//            
//            // If we haven't recorded the start state, this is the first change.
//            if initialStickerState == nil {
//                initialStickerState = (
//                    pos: CGPoint(x: entry!.stickers[index].posX, y: entry!.stickers[index].posY),
//                    scale: entry!.stickers[index].scale,
//                    rot: entry!.stickers[index].rotationDegrees
//                )
//            }
//            
//            // Apply the drag translation to the starting position.
//            let newPosX = initialStickerState!.pos.x + (value.translation.width / canvasSize.width)
//            let newPosY = initialStickerState!.pos.y + (value.translation.height / canvasSize.height)
//            
//            entry?.stickers[index].posX = newPosX
//            entry?.stickers[index].posY = newPosY
//        } else {
//            // No sticker selected, apply to background
//            // GestureState updates backgroundGestureOffset directly, nothing else needed here for onChanged
//        }
//    }
//    
//    func handleUnifiedDragEnd(_ value: DragGesture.Value, canvasSize: CGSize) {
//        // Was this a simple tap? (Threshold for drag vs tap)
//        if abs(value.translation.width) < 5 && abs(value.translation.height) < 5 {
//            // It was a tap. Perform a hit-test.
//            if let tappedSticker = sticker(at: value.startLocation, in: canvasSize) {
//                // Tap on a sticker -> Select it.
//                selectedStickerID = tappedSticker.id
//            } else {
//                // Tap on background -> Deselect any selected sticker and commit text.
//                selectedStickerID = nil
//                commitTypingIfNeeded(containerSize: canvasSize)
//                typingFieldFocused = false
//            }
//        } else {
//            // This was a drag.
//            if let selectedStickerID = selectedStickerID,
//               let index = entry?.stickers.firstIndex(where: { $0.id == selectedStickerID }) {
//                
//                // Finalize the sticker position and clamp it.
//                entry?.stickers[index].posX = min(max(entry!.stickers[index].posX, 0.0), 1.0)
//                entry?.stickers[index].posY = min(max(entry!.stickers[index].posY, 0.0), 1.0)
//                
//                try? modelContext.save()
//            } else {
//                // No sticker selected, finalize background offset
//                currentOffset.width += value.translation.width
//                currentOffset.height += value.translation.height
//                try? modelContext.save()
//            }
//        }
//        
//        // Reset the state for the next gesture.
//        initialStickerState = nil
//    }
//
//    func handleUnifiedScaleChange(_ value: MagnificationGesture.Value, canvasSize: CGSize) {
//        if let selectedStickerID = selectedStickerID,
//           let index = entry?.stickers.firstIndex(where: { $0.id == selectedStickerID }) {
//            
//            if initialStickerState == nil {
//                initialStickerState = (
//                    pos: CGPoint(x: entry!.stickers[index].posX, y: entry!.stickers[index].posY),
//                    scale: entry!.stickers[index].scale,
//                    rot: entry!.stickers[index].rotationDegrees
//                )
//            }
//            entry?.stickers[index].scale = initialStickerState!.scale * value
//        } else {
//            // No sticker selected, apply to background
//            // GestureState updates backgroundGestureScale directly, nothing else needed here for onChanged
//        }
//    }
//    
//    func handleUnifiedScaleEnd(_ value: MagnificationGesture.Value, canvasSize: CGSize) {
//        if let selectedStickerID = selectedStickerID,
//           let index = entry?.stickers.firstIndex(where: { $0.id == selectedStickerID }),
//           let initial = initialStickerState {
//            
//            entry?.stickers[index].scale = initial.scale * value
//            try? modelContext.save()
//        } else {
//            // No sticker selected, finalize background scale
//            currentScale *= value
//            try? modelContext.save()
//        }
//        initialStickerState = nil
//    }
//
//    func handleUnifiedRotationChange(_ value: RotationGesture.Value, canvasSize: CGSize) {
//        if let selectedStickerID = selectedStickerID,
//           let index = entry?.stickers.firstIndex(where: { $0.id == selectedStickerID }) {
//
//            if initialStickerState == nil {
//                initialStickerState = (
//                    pos: CGPoint(x: entry!.stickers[index].posX, y: entry!.stickers[index].posY),
//                    scale: entry!.stickers[index].scale,
//                    rot: entry!.stickers[index].rotationDegrees
//                )
//            }
//            entry?.stickers[index].rotationDegrees = initialStickerState!.rot + value.degrees
//        }
//    }
//    
//    func handleUnifiedRotationEnd(_ value: RotationGesture.Value, canvasSize: CGSize) {
//        if let selectedStickerID = selectedStickerID,
//           let index = entry?.stickers.firstIndex(where: { $0.id == selectedStickerID }),
//           let initial = initialStickerState {
//            
//            entry?.stickers[index].rotationDegrees = initial.rot + value.degrees
//            try? modelContext.save()
//        }
//        // No rotation for background image, so no else block
//        initialStickerState = nil
//    }
//    
//    func sticker(at location: CGPoint, in containerSize: CGSize) -> StickerInfo? {
//        guard let entry = entry else { return nil }
//        // Iterate in reverse order to pick the topmost sticker visually
//        for sticker in entry.stickers.reversed() {
//            // Calculate actual sticker center in absolute coordinates
//            let stickerCenterX = sticker.posX * containerSize.width
//            let stickerCenterY = sticker.posY * containerSize.height
//            
//            // Assuming default sticker size is 50x50 at scale 1.0 (or whatever StickerView's default is)
//            let stickerBaseSize: CGFloat = 50
//            let currentStickerWidth = stickerBaseSize * sticker.scale
//            let currentStickerHeight = stickerBaseSize * sticker.scale
//            
//            // Create a bounding box for hit-testing
//            // Apply a small padding for easier tapping
//            let hitTestPadding: CGFloat = 20
//            let hitTestFrame = CGRect(
//                x: stickerCenterX - (currentStickerWidth / 2) - hitTestPadding,
//                y: stickerCenterY - (currentStickerHeight / 2) - hitTestPadding,
//                width: currentStickerWidth + (2 * hitTestPadding),
//                height: currentStickerHeight + (2 * hitTestPadding)
//            )
//
//            if hitTestFrame.contains(location) {
//                return sticker
//            }
//        }
//        return nil
//    }
//}
//
//// ... Actions and other helpers are correct ...
//// MARK: - Actions
//private extension DayDetailView {
//
//    func commitTypingIfNeeded(containerSize: CGSize) {
//        guard !currentTypingText.isEmpty else { return }
//        let entryToUpdate = createOrGetEntry()
//        let newSticker = StickerInfo(type: .text, content: currentTypingText)
//        entryToUpdate.stickers.append(newSticker)
//        try? modelContext.save()
//        selectedStickerID = newSticker.id // Select the newly created text sticker
//        currentTypingText = ""
//        isTyping = false
//    }
//
//    func saveBackgroundState() {
//        guard let entry = entry else { return }
//        entry.backgroundImageScale = currentScale
//        entry.backgroundImageOffsetX = currentOffset.width
//        entry.backgroundImageOffsetY = currentOffset.height
//        // This is now saved immediately in handleUnifiedDragEnd and handleUnifiedScaleEnd,
//        // so this onDisappear save is less critical but harmless as a fallback.
//        try? modelContext.save()
//    }
//
//    func loadPhoto(_ newItem: PhotosPickerItem?) {
//        Task {
//            guard let data = try? await newItem?.loadTransferable(type: Data.self) else { return }
//            let entryToUpdate = createOrGetEntry()
//            withAnimation {
//                entryToUpdate.backgroundImageData = data
//                entryToUpdate.backgroundImageScale = 1.0
//                entryToUpdate.backgroundImageOffsetX = 0
//                entryToUpdate.backgroundImageOffsetY = 0
//                currentScale = 1.0
//                currentOffset = .zero
//            }
//            try? modelContext.save()
//        }
//    }
//
//    func fetchEntry(for date: Date) async {
//        let startOfDay = Calendar.current.startOfDay(for: date)
//        let predicate = #Predicate<DayEntry> { $0.date == startOfDay }
//        let descriptor = FetchDescriptor(predicate: predicate)
//
//        do {
//            let entries = try modelContext.fetch(descriptor)
//            self.entry = entries.first
//
//            if let entry = self.entry {
//                currentScale = entry.backgroundImageScale
//                currentOffset = CGSize(width: entry.backgroundImageOffsetX,
//                                       height: entry.backgroundImageOffsetY)
//            } else {
//                currentScale = 1.0
//                currentOffset = .zero
//            }
//        } catch {
//            print("Failed to fetch entry: \(error)")
//        }
//    }
//
//    func createOrGetEntry() -> DayEntry {
//        if let existingEntry = self.entry { return existingEntry }
//        let newEntry = DayEntry(date: Calendar.current.startOfDay(for: date))
//        modelContext.insert(newEntry)
//        self.entry = newEntry
//        return newEntry
//    }
//}

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

    // Background image gesture states
    @GestureState private var backgroundGestureScale: CGFloat = 1.0
    @GestureState private var backgroundGestureOffset: CGSize = .zero

    @State private var selectedStickerID: UUID?

    // Sticker gesture states (unified)
    @State private var initialStickerState: (pos: CGPoint, scale: CGFloat, rot: Double)?
    @GestureState private var stickerGestureScale: CGFloat = 1.0
    @GestureState private var stickerGestureOffset: CGSize = .zero
    @GestureState private var stickerGestureRotation: Angle = .zero

    @State private var currentTypingText: String = ""
    @State private var isTyping: Bool = false
    @FocusState private var typingFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack {
                editorView
                toolbarView
                hiddenTextField
            }
            .navigationTitle("Edit Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarDoneButton }
        }
        .task(id: date) { await fetchEntry(for: date) }
        .onDisappear { saveBackgroundState() }
        .onChange(of: selectedPhoto) { _, newItem in loadPhoto(newItem) }
    }
}

// MARK: - Subviews
private extension DayDetailView {

    var editorView: some View {
        GeometryReader { geometry in
            let canvasSize = geometry.size
            ZStack {
                backgroundImageView(canvasSize: canvasSize)
                stickersLayer(containerSize: canvasSize)
                typingPreview

                // --- FIXED: Conditional gesture updates ---
                Rectangle()
                    .fill(Color.white.opacity(0.01)) // Invisible touch area
                    .contentShape(Rectangle())
                    .gesture(
                        SimultaneousGesture(
                            SimultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .updating($stickerGestureOffset) { value, state, _ in
                                        if selectedStickerID != nil {
                                            state = value.translation
                                        }
                                    }
                                    .updating($backgroundGestureOffset) { value, state, _ in
                                        if selectedStickerID == nil {
                                            state = value.translation
                                        }
                                    }
                                    .onChanged { value in
                                        handleUnifiedDragChange(value, canvasSize: canvasSize)
                                    }
                                    .onEnded { value in
                                        handleUnifiedDragEnd(value, canvasSize: canvasSize)
                                    },
                                MagnificationGesture()
                                    .updating($stickerGestureScale) { value, state, _ in
                                        if selectedStickerID != nil {
                                            state = value
                                        }
                                    }
                                    .updating($backgroundGestureScale) { value, state, _ in
                                        if selectedStickerID == nil {
                                            state = value
                                        }
                                    }
                                    .onChanged { value in
                                        handleUnifiedScaleChange(value, canvasSize: canvasSize)
                                    }
                                    .onEnded { value in
                                        handleUnifiedScaleEnd(value, canvasSize: canvasSize)
                                    }
                            ),
                            RotationGesture()
                                .updating($stickerGestureRotation) { value, state, _ in
                                    if selectedStickerID != nil {
                                        state = value
                                    }
                                }
                                .onChanged { value in
                                    handleUnifiedRotationChange(value, canvasSize: canvasSize)
                                }
                                .onEnded { value in
                                    handleUnifiedRotationEnd(value, canvasSize: canvasSize)
                                }
                        )
                    )
            }
            .frame(width: AppConstants.editorPreviewWidth,
                   height: AppConstants.editorPreviewHeight)
            .overlay(Rectangle().stroke(Color.white.opacity(0.8), lineWidth: 2))
        }
        .frame(width: AppConstants.editorPreviewWidth,
               height: AppConstants.editorPreviewHeight)
    }

    var toolbarView: some View {
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
                // Placeholder for future drawing tools
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
                    try? modelContext.save()
                }
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 24))
            }
        }
        .padding(.top, 8)
    }

    var hiddenTextField: some View {
        TextField("", text: $currentTypingText)
            .focused($typingFieldFocused)
            .frame(width: 0, height: 0)
            .opacity(0.01)
            .onChange(of: currentTypingText) { _ in isTyping = true }
    }

    var toolbarDoneButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Done") {
                commitTypingIfNeeded(containerSize: CGSize(width: AppConstants.editorPreviewWidth,
                                                           height: AppConstants.editorPreviewHeight))
                dismiss()
            }
        }
    }

    var typingPreview: some View {
        Group {
            if isTyping && !currentTypingText.isEmpty {
                Text(currentTypingText)
                    .padding(4)
                    .background(Color.clear)
                    .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(Color.accentColor, lineWidth: 1))
            }
        }
    }

    func backgroundImageView(canvasSize: CGSize) -> some View {
        Group {
            if let entry = entry,
               let imageData = entry.backgroundImageData,
               let uiImage = UIImage(data: imageData) {

                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(currentScale * backgroundGestureScale)
                    .offset(x: currentOffset.width + backgroundGestureOffset.width,
                            y: currentOffset.height + backgroundGestureOffset.height)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.black.opacity(0.1))
            }
        }
    }

    func stickersLayer(containerSize: CGSize) -> some View {
        Group {
            if let entry = entry {
                ForEach(entry.stickers) { sticker in
                    StickerView(
                        sticker: sticker,
                        containerSize: containerSize,
                        isSelected: selectedStickerID == sticker.id
                    )
                }
            }
        }
    }
}

// MARK: - Gestures
private extension DayDetailView {

    func handleUnifiedDragChange(_ value: DragGesture.Value, canvasSize: CGSize) {
        if let selectedStickerID = selectedStickerID,
           let index = entry?.stickers.firstIndex(where: { $0.id == selectedStickerID }) {

            // If we haven't recorded the start state, this is the first change.
            if initialStickerState == nil {
                initialStickerState = (
                    pos: CGPoint(x: entry!.stickers[index].posX, y: entry!.stickers[index].posY),
                    scale: entry!.stickers[index].scale,
                    rot: entry!.stickers[index].rotationDegrees
                )
            }

            // Apply the drag translation to the starting position (posX/posY are normalized 0..1).
            let newPosX = initialStickerState!.pos.x + (value.translation.width / canvasSize.width)
            let newPosY = initialStickerState!.pos.y + (value.translation.height / canvasSize.height)

            entry?.stickers[index].posX = newPosX
            entry?.stickers[index].posY = newPosY
        } else {
            // No sticker selected, apply to background
            // live updates handled via @GestureState backgroundGestureOffset so nothing required here
        }
    }

    func handleUnifiedDragEnd(_ value: DragGesture.Value, canvasSize: CGSize) {
        // Was this a simple tap? (Threshold for drag vs tap)
        if abs(value.translation.width) < 5 && abs(value.translation.height) < 5 {
            // It was a tap. Perform a hit-test.
            if let tappedSticker = sticker(at: value.startLocation, in: canvasSize) {
                // Tap on a sticker -> Select it.
                selectedStickerID = tappedSticker.id
            } else {
                // Tap on background -> Deselect any selected sticker and commit text.
                selectedStickerID = nil
                commitTypingIfNeeded(containerSize: canvasSize)
                typingFieldFocused = false
            }
        } else {
            // This was a drag.
            if let selectedStickerID = selectedStickerID,
               let index = entry?.stickers.firstIndex(where: { $0.id == selectedStickerID }) {

                // Finalize the sticker position and clamp it.
                entry?.stickers[index].posX = min(max(entry!.stickers[index].posX, 0.0), 1.0)
                entry?.stickers[index].posY = min(max(entry!.stickers[index].posY, 0.0), 1.0)

                try? modelContext.save()
            } else {
                // No sticker selected, finalize background offset
                currentOffset.width += value.translation.width
                currentOffset.height += value.translation.height
                try? modelContext.save()
            }
        }

        // Reset the state for the next gesture.
        initialStickerState = nil
    }

    func handleUnifiedScaleChange(_ value: MagnificationGesture.Value, canvasSize: CGSize) {
        if let selectedStickerID = selectedStickerID,
           let index = entry?.stickers.firstIndex(where: { $0.id == selectedStickerID }) {

            if initialStickerState == nil {
                initialStickerState = (
                    pos: CGPoint(x: entry!.stickers[index].posX, y: entry!.stickers[index].posY),
                    scale: entry!.stickers[index].scale,
                    rot: entry!.stickers[index].rotationDegrees
                )
            }
            entry?.stickers[index].scale = initialStickerState!.scale * value
        } else {
            // No sticker selected, apply to background
            // live updates handled via @GestureState backgroundGestureScale so nothing required here
        }
    }

    func handleUnifiedScaleEnd(_ value: MagnificationGesture.Value, canvasSize: CGSize) {
        if let selectedStickerID = selectedStickerID,
           let index = entry?.stickers.firstIndex(where: { $0.id == selectedStickerID }),
           let initial = initialStickerState {

            entry?.stickers[index].scale = initial.scale * value
            try? modelContext.save()
        } else {
            // No sticker selected, finalize background scale
            currentScale *= value
            try? modelContext.save()
        }
        initialStickerState = nil
    }

    func handleUnifiedRotationChange(_ value: RotationGesture.Value, canvasSize: CGSize) {
        if let selectedStickerID = selectedStickerID,
           let index = entry?.stickers.firstIndex(where: { $0.id == selectedStickerID }) {

            if initialStickerState == nil {
                initialStickerState = (
                    pos: CGPoint(x: entry!.stickers[index].posX, y: entry!.stickers[index].posY),
                    scale: entry!.stickers[index].scale,
                    rot: entry!.stickers[index].rotationDegrees
                )
            }
            entry?.stickers[index].rotationDegrees = initialStickerState!.rot + value.degrees
        }
    }

    func handleUnifiedRotationEnd(_ value: RotationGesture.Value, canvasSize: CGSize) {
        if let selectedStickerID = selectedStickerID,
           let index = entry?.stickers.firstIndex(where: { $0.id == selectedStickerID }),
           let initial = initialStickerState {

            entry?.stickers[index].rotationDegrees = initial.rot + value.degrees
            try? modelContext.save()
        }
        // No rotation for background image
        initialStickerState = nil
    }

    func sticker(at location: CGPoint, in containerSize: CGSize) -> StickerInfo? {
        guard let entry = entry else { return nil }
        // Iterate in reverse order to pick the topmost sticker visually
        for sticker in entry.stickers.reversed() {
            // Calculate actual sticker center in absolute coordinates
            let stickerCenterX = sticker.posX * containerSize.width
            let stickerCenterY = sticker.posY * containerSize.height

            // Assuming default sticker size is 50x50 at scale 1.0
            let stickerBaseSize: CGFloat = 50
            let currentStickerWidth = stickerBaseSize * sticker.scale
            let currentStickerHeight = stickerBaseSize * sticker.scale

            // Create a bounding box for hit-testing
            // Apply a small padding for easier tapping
            let hitTestPadding: CGFloat = 20
            let hitTestFrame = CGRect(
                x: stickerCenterX - (currentStickerWidth / 2) - hitTestPadding,
                y: stickerCenterY - (currentStickerHeight / 2) - hitTestPadding,
                width: currentStickerWidth + (2 * hitTestPadding),
                height: currentStickerHeight + (2 * hitTestPadding)
            )

            if hitTestFrame.contains(location) {
                return sticker
            }
        }
        return nil
    }
}

// MARK: - Actions
private extension DayDetailView {

    func commitTypingIfNeeded(containerSize: CGSize) {
        guard !currentTypingText.isEmpty else { return }
        let entryToUpdate = createOrGetEntry()
        let newSticker = StickerInfo(type: .text, content: currentTypingText)
        entryToUpdate.stickers.append(newSticker)
        try? modelContext.save()
        selectedStickerID = newSticker.id // Select the newly created text sticker
        currentTypingText = ""
        isTyping = false
    }

    func saveBackgroundState() {
        guard let entry = entry else { return }
        entry.backgroundImageScale = currentScale
        entry.backgroundImageOffsetX = currentOffset.width
        entry.backgroundImageOffsetY = currentOffset.height
        // Also safe to call save here
        try? modelContext.save()
    }

    func loadPhoto(_ newItem: PhotosPickerItem?) {
        Task {
            guard let data = try? await newItem?.loadTransferable(type: Data.self) else { return }
            let entryToUpdate = createOrGetEntry()
            withAnimation {
                entryToUpdate.backgroundImageData = data
                entryToUpdate.backgroundImageScale = 1.0
                entryToUpdate.backgroundImageOffsetX = 0
                entryToUpdate.backgroundImageOffsetY = 0
                currentScale = 1.0
                currentOffset = .zero
            }
            try? modelContext.save()
        }
    }

    func fetchEntry(for date: Date) async {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let predicate = #Predicate<DayEntry> { $0.date == startOfDay }
        let descriptor = FetchDescriptor(predicate: predicate)

        do {
            let entries = try modelContext.fetch(descriptor)
            self.entry = entries.first

            if let entry = self.entry {
                currentScale = entry.backgroundImageScale
                currentOffset = CGSize(width: entry.backgroundImageOffsetX,
                                       height: entry.backgroundImageOffsetY)
            } else {
                currentScale = 1.0
                currentOffset = .zero
            }
        } catch {
            print("Failed to fetch entry: \(error)")
        }
    }

    func createOrGetEntry() -> DayEntry {
        if let existingEntry = self.entry { return existingEntry }
        let newEntry = DayEntry(date: Calendar.current.startOfDay(for: date))
        modelContext.insert(newEntry)
        self.entry = newEntry
        return newEntry
    }
}
