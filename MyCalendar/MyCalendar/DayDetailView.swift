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
//    @State private var showingEmoticonEditor = false
//
//    @Environment(\.modelContext) private var modelContext
//    @Environment(\.dismiss) private var dismiss
//    let date: Date
//
//    @State private var entry: DayEntry?
//    @State private var selectedPhoto: PhotosPickerItem?
//    
//    @State private var currentScale: CGFloat = 1.0
//    @State private var currentOffset: CGSize = .zero
//    @GestureState private var gestureScale: CGFloat = 1.0
//    @GestureState private var gestureOffset: CGSize = .zero
//
//    var body: some View {
//        let magnificationGesture = MagnificationGesture()
//            .updating($gestureScale) { value, state, _ in state = value }
//            .onEnded { value in currentScale *= value }
//
//        let dragGesture = DragGesture()
//            .updating($gestureOffset) { value, state, _ in state = value.translation }
//            .onEnded { value in
//                currentOffset.width += value.translation.width
//                currentOffset.height += value.translation.height
//            }
//
//        let combinedGesture = SimultaneousGesture(magnificationGesture, dragGesture)
//
//        NavigationStack {
//            VStack(spacing: 20) {
//                // --- PREVIEW RECTANGLE ---
//                ZStack {
//                    if let entry = entry, let imageData = entry.backgroundImageData, let uiImage = UIImage(data: imageData) {
//                        Image(uiImage: uiImage)
//                            .resizable()
//                            .scaledToFill()
//                            .scaleEffect(currentScale * gestureScale)
//                            .offset(
//                                x: currentOffset.width + gestureOffset.width,
//                                y: currentOffset.height + gestureOffset.height
//                            )
//                            .clipped()
//                    } else {
//                        Rectangle()
//                            .fill(Color.secondary.opacity(0.1))
//                            .overlay(Text("No Background"))
//                    }
//
//                    // Show emojis on top
//                    if let entry = entry {
//                        ForEach(entry.emoticons) { emoticon in
//                            Text(emoticon.character)
//                                .font(.system(size: 32))
//                                .padding(4)
//                        }
//                    }
//                }
//                .frame(width: AppConstants.editorPreviewWidth,
//                       height: AppConstants.editorPreviewHeight)
//                .overlay(
//                    Rectangle()
//                        .stroke(Color.white.opacity(0.8), lineWidth: 2)
//                )
//                .gesture(combinedGesture)
//
//                // --- TOOLBAR ICONS ---
//                HStack(spacing: 40) {
//                    // Background Image Picker
//                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
//                        Image(systemName: "photo.on.rectangle")
//                            .font(.system(size: 30))
//                    }
//
//                    // Add Emoticon
//                    Button {
//                        showingEmoticonEditor = true
//                    } label: {
//                        Image(systemName: "face.smiling")
//                            .font(.system(size: 30))
//                    }
//
//                    // Drawing (future)
//                    Button {
//                        // TODO: open drawing editor
//                    } label: {
//                        Image(systemName: "pencil.tip")
//                            .font(.system(size: 30))
//                    }
//                }
//                .padding(.top, 10)
//
//                // --- REMOVE BACKGROUND BUTTON ---
//                if let entry = entry, entry.backgroundImageData != nil {
//                    Button(role: .destructive) {
//                        withAnimation {
//                            entry.backgroundImageData = nil
//                            entry.backgroundImageScale = 1.0
//                            entry.backgroundImageOffsetX = 0.0
//                            entry.backgroundImageOffsetY = 0.0
//                        }
//                    } label: {
//                        Label("Remove Background Image", systemImage: "trash")
//                    }
//                    .padding(.top)
//                }
//
//                Spacer()
//            }
//            .navigationTitle("Customize Day")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Done") { dismiss() }
//                }
//            }
//        }
//        .task(id: date) {
//            await fetchEntry(for: date)
//        }
//        .onDisappear {
//            if let entry = entry {
//                entry.backgroundImageScale = self.currentScale
//                entry.backgroundImageOffsetX = self.currentOffset.width
//                entry.backgroundImageOffsetY = self.currentOffset.height
//                try? modelContext.save()
//            }
//        }
//        .onChange(of: selectedPhoto) { _, newItem in
//            Task {
//                guard let data = try? await newItem?.loadTransferable(type: Data.self) else { return }
//                let entryToUpdate = createOrGetEntry()
//                withAnimation {
//                    entryToUpdate.backgroundImageData = data
//                    entryToUpdate.backgroundImageScale = 1.0
//                    entryToUpdate.backgroundImageOffsetX = 0
//                    entryToUpdate.backgroundImageOffsetY = 0
//                    self.currentScale = 1.0
//                    self.currentOffset = .zero
//                }
//            }
//        }
//        .sheet(isPresented: $showingEmoticonEditor) {
//            let entryToEdit = createOrGetEntry()
//            EmoticonEditorView(dayEntry: entryToEdit)
//        }
//    }
//    
//    private func fetchEntry(for date: Date) async {
//        let startOfDay = Calendar.current.startOfDay(for: date)
//        let predicate = #Predicate<DayEntry> { $0.date == startOfDay }
//        let descriptor = FetchDescriptor(predicate: predicate)
//        
//        do {
//            let entries = try modelContext.fetch(descriptor)
//            self.entry = entries.first
//            
//            if let entry = self.entry {
//                self.currentScale = entry.backgroundImageScale
//                self.currentOffset = CGSize(width: entry.backgroundImageOffsetX, height: entry.backgroundImageOffsetY)
//            } else {
//                self.currentScale = 1.0
//                self.currentOffset = .zero
//            }
//        } catch {
//            print("Failed to fetch entry: \(error)")
//        }
//    }
//    
//    private func createOrGetEntry() -> DayEntry {
//        if let existingEntry = self.entry {
//            return existingEntry
//        } else {
//            let newEntry = DayEntry(date: Calendar.current.startOfDay(for: date))
//            modelContext.insert(newEntry)
//            self.entry = newEntry
//            return newEntry
//        }
//    }
//}

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
    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureOffset: CGSize = .zero
    
    // Editing states
    @FocusState private var textFieldFocused: Bool
    @State private var newText: String = ""
    
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
                // --- Main editable rectangle (slightly smaller) ---
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
                }
                .frame(
                    width: AppConstants.editorPreviewWidth * 0.9,   // smaller but same ratio
                    height: AppConstants.editorPreviewHeight * 0.9
                )
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.8), lineWidth: 2)
                )
                .padding(.top, 10)
                
                // --- Toolbar with centered icons ---
                HStack(spacing: 40) {
                    // Background image picker
                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 24))
                    }
                    
                    // Keyboard / text entry
                    Button {
                        textFieldFocused = true
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
                    
                    // Recycle bin (delete background image)
                    Button(role: .destructive) {
                        if let entry = entry {
                            withAnimation {
                                entry.backgroundImageData = nil
                                entry.backgroundImageScale = 1.0
                                entry.backgroundImageOffsetX = 0.0
                                entry.backgroundImageOffsetY = 0.0
                            }
                        }
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 24))
                            .foregroundColor(.red)
                    }
                }
                .padding(.vertical, 12)
                
                // Hidden textfield to trigger keyboard
                TextField("", text: $newText)
                    .focused($textFieldFocused)
                    .frame(width: 0, height: 0)
                    .opacity(0.01)
                    .onChange(of: newText) { _, newValue in
                        if !newValue.isEmpty {
                            let entryToUpdate = createOrGetEntry()
                            entryToUpdate.emoticons.append(EmoticonInfo(character: newValue))
                            newText = ""
                        }
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
                entry.backgroundImageScale = self.currentScale
                entry.backgroundImageOffsetX = self.currentOffset.width
                entry.backgroundImageOffsetY = self.currentOffset.height
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
    
    // --- Helpers ---
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
