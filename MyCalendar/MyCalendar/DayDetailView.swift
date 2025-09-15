//
//  DayDetailView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 23. 7. 2025..
//

//import SwiftUI
//import PhotosUI
//import SwiftData
//
//struct DayDetailView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Environment(\.dismiss) private var dismiss
//
//    let date: Date
//
//    @State private var entry: DayEntry?
//    @State private var selectedPhoto: PhotosPickerItem?
//
//    // Background image transform state
//    @State private var currentScale: CGFloat = 1.0
//    @State private var currentOffset: CGSize = .zero
//    @GestureState private var gestureScale: CGFloat = 1.0
//    @GestureState private var gestureOffset: CGSize = .zero
//
//    // Selection is tracked by sticker ID (UUID) to avoid reference/staleness issues
//    @State private var selectedStickerID: UUID?
//
//    // Typing state
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
//            }
//            .frame(width: AppConstants.editorPreviewWidth,
//                   height: AppConstants.editorPreviewHeight)
//            .overlay(Rectangle().stroke(Color.white.opacity(0.8), lineWidth: 2))
//            .onTapGesture {
//                // If keyboard is open, dismiss it (but keep sticker selection).
//                // If keyboard is already closed, a tap clears selection.
//                if typingFieldFocused {
//                    commitTypingIfNeeded(containerSize: canvasSize)
//                    typingFieldFocused = false
//                } else {
//                    selectedStickerID = nil
//                }
//            }
//        }
//        .frame(width: AppConstants.editorPreviewWidth,
//               height: AppConstants.editorPreviewHeight)
//    }
//
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
//                    .scaleEffect(currentScale * gestureScale)
//                    .offset(x: currentOffset.width + gestureOffset.width,
//                            y: currentOffset.height + gestureOffset.height)
//                    .clipped()
//                    .gesture(selectedStickerID == nil ? backgroundGesture : nil)
//            } else {
//                Rectangle()
//                    .fill(Color.black.opacity(0.1))
//                    .gesture(selectedStickerID == nil ? backgroundGesture : nil)
//            }
//        }
//    }
//
//    func stickersLayer(containerSize: CGSize) -> some View {
//        Group {
//            if let entry = entry {
//                ForEach(entry.stickers.indices, id: \.self) { index in
//                    // Binding to the sticker in the DayEntry array so StickerView can mutate it directly.
//                    let binding = Binding<StickerInfo>(
//                        get: { entry.stickers[index] },
//                        set: { newValue in
//                            guard let e = self.entry else { return }
//                            e.stickers[index] = newValue
//                            try? modelContext.save()
//                        }
//                    )
//
//                    StickerView(
//                        sticker: binding,
//                        containerSize: containerSize,
//                        selectedStickerID: $selectedStickerID
//                    )
//                    // Persist small changes (position/scale/rotation) when they change.
//                    .onChange(of: entry.stickers[index].posX) { _, _ in
//                        saveStickerPosition(entry.stickers[index], in: containerSize)
//                    }
//                    .onChange(of: entry.stickers[index].posY) { _, _ in
//                        saveStickerPosition(entry.stickers[index], in: containerSize)
//                    }
//                    .onChange(of: entry.stickers[index].scale) { _, _ in
//                        saveStickerPosition(entry.stickers[index], in: containerSize)
//                    }
//                    .onChange(of: entry.stickers[index].rotationDegrees) { _, _ in
//                        saveStickerPosition(entry.stickers[index], in: containerSize)
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Gestures
//private extension DayDetailView {
//    var backgroundGesture: some Gesture {
//        SimultaneousGesture(
//            MagnificationGesture()
//                .updating($gestureScale) { value, state, _ in state = value }
//                .onEnded { value in currentScale *= value },
//            DragGesture()
//                .updating($gestureOffset) { value, state, _ in state = value.translation }
//                .onEnded { value in
//                    currentOffset.width += value.translation.width
//                    currentOffset.height += value.translation.height
//                }
//        )
//    }
//}
//
//// MARK: - Actions
//private extension DayDetailView {
//
//    func commitTypingIfNeeded(containerSize: CGSize) {
//        guard !currentTypingText.isEmpty else { return }
//        let entryToUpdate = createOrGetEntry()
//        let newSticker = StickerInfo(type: .text, content: currentTypingText)
//        entryToUpdate.stickers.append(newSticker)
//        // Save immediately and select the new sticker for immediate manipulation
//        saveStickerPosition(newSticker, in: containerSize)
//        try? modelContext.save()
//        selectedStickerID = newSticker.id
//        currentTypingText = ""
//        isTyping = false
//    }
//
//    func saveStickerPosition(_ sticker: StickerInfo, in containerSize: CGSize) {
//        // relativePos kept for future compatibility; here posX/posY already normalized
//        sticker.relativePosX = sticker.posX
//        sticker.relativePosY = sticker.posY
//        try? modelContext.save()
//    }
//
//    func saveBackgroundState() {
//        guard let entry = entry else { return }
//        entry.backgroundImageScale = currentScale
//        entry.backgroundImageOffsetX = currentOffset.width
//        entry.backgroundImageOffsetY = currentOffset.height
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

    @State private var selectedStickerID: UUID?
    
    // --- THIS IS THE CORRECT STATE VARIABLE FOR TRACKING A DRAG ---
    @State private var initialStickerPosition: CGPoint?

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
            }
            .frame(width: AppConstants.editorPreviewWidth,
                   height: AppConstants.editorPreviewHeight)
            .overlay(Rectangle().stroke(Color.white.opacity(0.8), lineWidth: 2))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleDragChange(value, canvasSize: canvasSize)
                    }
                    .onEnded { value in
                        handleDragEnd(value, canvasSize: canvasSize)
                    }
            )
        }
        .frame(width: AppConstants.editorPreviewWidth,
               height: AppConstants.editorPreviewHeight)
    }

    // ... other subviews are correct ...
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
            .onChange(of: currentTypingText) { isTyping = true }
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
                    .scaleEffect(currentScale * gestureScale)
                    .offset(x: currentOffset.width + gestureOffset.width,
                            y: currentOffset.height + gestureOffset.height)
                    .clipped()
                    .gesture(selectedStickerID == nil ? backgroundGesture : nil)
            } else {
                Rectangle()
                    .fill(Color.black.opacity(0.1))
            }
        }
    }

    // --- YOUR ROBUST `stickersLayer` FUNCTION ---
    func stickersLayer(containerSize: CGSize) -> some View {
        // We wrap in a Group to provide a single, unambiguous return type for the function.
        Group {
            // We safely unwrap the optional 'entry' object.
            if let entry = entry {
                // We iterate over the *indices* of the stickers array for a stable binding.
                ForEach(entry.stickers.indices, id: \.self) { index in
                    // We create a direct, robust binding to the sticker at this index.
                    let stickerBinding = Binding<StickerInfo>(
                        get: {
                            // These safety checks prevent crashes if the array changes.
                            guard entry.stickers.indices.contains(index) else {
                                return StickerInfo(type: .text, content: "") // Return a dummy
                            }
                            return entry.stickers[index]
                        },
                        set: { newValue in
                            guard entry.stickers.indices.contains(index) else { return }
                            entry.stickers[index] = newValue
                        }
                    )
                    
                    // --- THE DEFINITIVE FIX FOR ALL 3 ERRORS ---
                    // We now call the new, simplified StickerView correctly.
                    StickerView(
                        sticker: stickerBinding,
                        containerSize: containerSize,
                        // We calculate the 'isSelected' Bool right here.
                        isSelected: selectedStickerID == entry.stickers[index].id
                    )
                }
            }
        }
    }
}

// --- GESTURE LOGIC IS NOW REBUILT AND CORRECTED ---
private extension DayDetailView {
    var backgroundGesture: some Gesture {
        SimultaneousGesture(
            MagnificationGesture()
                .updating($gestureScale) { value, state, _ in state = value }
                .onEnded { value in currentScale *= value },
            DragGesture()
                .updating($gestureOffset) { value, state, _ in state = value.translation }
                .onEnded { value in
                    currentOffset.width += value.translation.width
                    currentOffset.height += value.translation.height
                }
        )
    }

    func handleDragChange(_ value: DragGesture.Value, canvasSize: CGSize) {
        if let selectedStickerID = selectedStickerID,
           let index = entry?.stickers.firstIndex(where: { $0.id == selectedStickerID }) {
            
            // --- THE CORRECT WAY TO DETECT THE START OF A DRAG ---
            if initialStickerPosition == nil {
                // If our state is nil, this is the first change. Record the starting position.
                initialStickerPosition = CGPoint(
                    x: entry!.stickers[index].posX,
                    y: entry!.stickers[index].posY
                )
            }
            
            // Now, apply the drag translation to the *recorded* starting position.
            let newPosX = initialStickerPosition!.x + (value.translation.width / canvasSize.width)
            let newPosY = initialStickerPosition!.y + (value.translation.height / canvasSize.height)
            
            // Update the sticker's position.
            entry?.stickers[index].posX = newPosX
            entry?.stickers[index].posY = newPosY
        }
    }
    
    func handleDragEnd(_ value: DragGesture.Value, canvasSize: CGSize) {
        if let selectedStickerID = selectedStickerID,
           let index = entry?.stickers.firstIndex(where: { $0.id == selectedStickerID }) {
            
            // Finalize the position and clamp it within bounds.
            entry?.stickers[index].posX = min(max(entry!.stickers[index].posX, 0.0), 1.0)
            entry?.stickers[index].posY = min(max(entry!.stickers[index].posY, 0.0), 1.0)
            
            // --- CRITICAL: Reset the state for the next gesture ---
            initialStickerPosition = nil
            
            try? modelContext.save()
            
        } else {
            // No sticker was selected. This was a tap.
            
            if value.translation.width < 5 && value.translation.height < 5 {
                if let tappedSticker = sticker(at: value.startLocation, in: canvasSize) {
                    // It was a tap on a sticker. Select it.
                    self.selectedStickerID = tappedSticker.id
                } else {
                    // It was a tap on the background. Deselect everything.
                    self.selectedStickerID = nil
                    commitTypingIfNeeded(containerSize: canvasSize)
                    typingFieldFocused = false
                }
            }
        }
    }
    
    func sticker(at location: CGPoint, in containerSize: CGSize) -> StickerInfo? {
        guard let entry = entry else { return nil }
        for sticker in entry.stickers.reversed() {
            let stickerFrame = CGRect(
                x: sticker.posX * containerSize.width,
                y: sticker.posY * containerSize.height,
                width: 50 * sticker.scale,
                height: 50 * sticker.scale
            )
            .offsetBy(dx: -25 * sticker.scale, dy: -25 * sticker.scale)
            .insetBy(dx: -20, dy: -20)

            if stickerFrame.contains(location) {
                return sticker
            }
        }
        return nil
    }
}

// ... Actions and other helpers are correct ...
// MARK: - Actions
private extension DayDetailView {

    func commitTypingIfNeeded(containerSize: CGSize) {
        guard !currentTypingText.isEmpty else { return }
        let entryToUpdate = createOrGetEntry()
        let newSticker = StickerInfo(type: .text, content: currentTypingText)
        entryToUpdate.stickers.append(newSticker)
        try? modelContext.save()
        selectedStickerID = newSticker.id
        currentTypingText = ""
        isTyping = false
    }

    func saveBackgroundState() {
        guard let entry = entry else { return }
        entry.backgroundImageScale = currentScale
        entry.backgroundImageOffsetX = currentOffset.width
        entry.backgroundImageOffsetY = currentOffset.height
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







