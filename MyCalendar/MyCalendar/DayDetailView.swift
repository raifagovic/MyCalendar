//
//  DayDetailView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 23. 7. 2025..
//

import SwiftUI
import PhotosUI
import SwiftData
import PencilKit

struct DayDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let date: Date

    @State private var entry: DayEntry?
    @State private var selectedPhoto: PhotosPickerItem?
    
    // Base font sizes in editor coordinate space (used so DayCellView can scale down exactly)
    private let baseEmojiFontSize: CGFloat = 24
    private let baseTextFontSize: CGFloat = 12

    // Add near other @State declarations
    private enum ScaleGestureTarget {
        case sticker(UUID)
        case background
    }

    @State private var activeScaleTarget: ScaleGestureTarget? = nil


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
    
    @State private var isDrawing: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                editorView
                toolbarView
                hiddenTextField
            }
            .navigationTitle("Edit Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Back button (left side)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        try? modelContext.save()   // save all changes
                        dismiss()                  // then dismiss detail view
                    }
                }
                
                // Done button (right side)
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        commitTypingIfNeeded(containerSize: CGSize(width: AppConstants.editorPreviewWidth,
                                                                   height: AppConstants.editorPreviewHeight))
                        saveBackgroundState()
                        try? modelContext.save()
                        
                        if isDrawing {
                            isDrawing = false   // just exit drawing mode
                        } else {
                            typingFieldFocused = false
                            isTyping = false    // just dismiss keyboard
                        }
                    }
                }
            }
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
                
                // Always show saved drawing
                if let data = entry?.drawingData,
                   let drawing = try? PKDrawing(data: data) {
                    Canvas { context, size in
                        let image = drawing.image(from: CGRect(origin: .zero, size: size), scale: 1)
                        context.draw(Image(uiImage: image), at: .zero)
                    }
                    .frame(width: AppConstants.editorPreviewWidth,
                           height: AppConstants.editorPreviewHeight)
                    .clipped()
                    .allowsHitTesting(false)
                }
                
                // Drawing layer
                if isDrawing {
                    if let entry = entry {
                        DrawingView(
                            drawingData: Binding(
                                get: { entry.drawingData },
                                set: { entry.drawingData = $0; try? modelContext.save() }
                            ),
                            isEditable: true,
                            showToolPicker: true
                        )
                        .frame(width: AppConstants.editorPreviewWidth,
                               height: AppConstants.editorPreviewHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.accentColor, lineWidth: 2)
                        )
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                    }
                }


                Rectangle()
                    .fill(Color.white.opacity(0.01)) // Invisible touch area
                    .contentShape(Rectangle())
                    .allowsHitTesting(!isDrawing)
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
                                        if selectedStickerID != nil { // ONLY update sticker state if sticker is selected
                                            state = value
                                        }
                                    }
                                    .updating($backgroundGestureScale) { value, state, _ in
                                        if selectedStickerID == nil { // ONLY update background state if NO sticker is selected
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
                                    if selectedStickerID != nil { // ONLY update sticker state if sticker is selected
                                        state = value
                                    }
                                }
                                // No backgroundGestureRotation needed
                                .onChanged { value in
                                    handleUnifiedRotationChange(value, canvasSize: canvasSize)
                                }
                                .onEnded { value in
                                    handleUnifiedRotationEnd(value, canvasSize: canvasSize)
                                }
                        )
                    )
                    .zIndex(0)
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
                isDrawing.toggle()
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

    // ---------------------------------------------------------------------
    // Stickers layer: render stickers using editor-space base font sizes.
    // This replaces the previous StickerView usage so the base font is
    // consistent with DayCellView's downscaling logic.
    // ---------------------------------------------------------------------
    func stickersLayer(containerSize: CGSize) -> some View {
        Group {
            if let entry = entry {
                ForEach(entry.stickers) { sticker in
                    // base font size defined in editor coordinates
                    let baseFontSize: CGFloat = (sticker.type == .emoji)
                        ? baseEmojiFontSize
                        : baseTextFontSize

                    Text(sticker.content.isEmpty ? " " : sticker.content)
                        .font(.system(size: baseFontSize))
                        .padding(sticker.type == .emoji ? .zero : 4)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(selectedStickerID == sticker.id ? Color.accentColor : Color.clear, lineWidth: 1)
                        )
                        .rotationEffect(.degrees(sticker.rotationDegrees))
                        .scaleEffect(sticker.scale)
                        .position(
                            x: sticker.posX * containerSize.width,
                            y: sticker.posY * containerSize.height
                        )
                        .onTapGesture {
                            selectedStickerID = sticker.id
                        }
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
        // Record the target once, at the start of the gesture
        if activeScaleTarget == nil {
            if let sel = selectedStickerID {
                activeScaleTarget = .sticker(sel)
            } else {
                activeScaleTarget = .background
            }
        }

        switch activeScaleTarget {
        case .sticker(let stickerID):
            guard let index = entry?.stickers.firstIndex(where: { $0.id == stickerID }) else { return }
            if initialStickerState == nil {
                initialStickerState = (
                    pos: CGPoint(x: entry!.stickers[index].posX, y: entry!.stickers[index].posY),
                    scale: entry!.stickers[index].scale,
                    rot: entry!.stickers[index].rotationDegrees
                )
            }
            // Live-scale the sticker only
            entry?.stickers[index].scale = initialStickerState!.scale * value

        case .background:
            // Background live preview is handled via @GestureState backgroundGestureScale.
            // Nothing to do here for live updates (we finalize in .onEnded).
            break

        case .none:
            break
        }
    }

    func handleUnifiedScaleEnd(_ value: MagnificationGesture.Value, canvasSize: CGSize) {
        defer {
            // Always reset for the next gesture
            initialStickerState = nil
            activeScaleTarget = nil
        }

        if let target = activeScaleTarget {
            switch target {
            case .sticker(let stickerID):
                // Finalize sticker scale
                if let index = entry?.stickers.firstIndex(where: { $0.id == stickerID }),
                   let initial = initialStickerState {
                    entry?.stickers[index].scale = initial.scale * value
                    try? modelContext.save()
                }

            case .background:
                // Finalize background scale
                currentScale *= value
                try? modelContext.save()
            }
        } else {
            // Fallback: if nothing recorded, behave like before
            if let selectedStickerID = selectedStickerID,
               let index = entry?.stickers.firstIndex(where: { $0.id == selectedStickerID }),
               let initial = initialStickerState {
                entry?.stickers[index].scale = initial.scale * value
                try? modelContext.save()
            } else {
                currentScale *= value
                try? modelContext.save()
            }
        }
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
            // No 'else' block needed here as background does not rotate.
        }

        func handleUnifiedRotationEnd(_ value: RotationGesture.Value, canvasSize: CGSize) {
            if let selectedStickerID = selectedStickerID,
               let index = entry?.stickers.firstIndex(where: { $0.id == selectedStickerID }),
               let initial = initialStickerState {

                // Finalize sticker rotation
                entry?.stickers[index].rotationDegrees = initial.rot + value.degrees
                try? modelContext.save()
            }
            // No 'else' block needed here because the background doesn't rotate.
            // We only save the sticker's rotation if it was selected.
            initialStickerState = nil // Reset
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


