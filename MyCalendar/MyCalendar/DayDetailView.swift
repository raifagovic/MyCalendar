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
    
    // --- NEW GESTURE STATE ---
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureOffset: CGSize = .zero

    // --- EDITOR CONSTANTS ---
    private let editorSize = CGSize(width: 300, height: 400)
    private var cropFrame: CGRect {
        let aspectRatio = AppConstants.calendarCellAspectRatio
        let width = editorSize.width
        let height = width / aspectRatio
        let x = (editorSize.width - width) / 2
        let y = (editorSize.height - height) / 2
        return CGRect(x: x, y: y, width: width, height: height)
    }

    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .updating($gestureScale) { value, state, _ in state = value }
            .onEnded { value in scale *= value }

        let dragGesture = DragGesture()
            .updating($gestureOffset) { value, state, _ in state = value.translation }
            .onEnded { value in
                offset.width += value.translation.width
                offset.height += value.translation.height
            }
        
        let combinedGesture = SimultaneousGesture(magnificationGesture, dragGesture)

        NavigationStack {
            VStack {
                if let _ = entry, let imageData = entry?.backgroundImageData, let uiImage = UIImage(data: imageData) {
                    
                    Text("Frame your image")
                        .font(.headline)
                        .padding(.top)

                    ZStack {
                        // The interactive image
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit() // Use scaledToFit for predictable geometry
                            .scaleEffect(scale * gestureScale)
                            .offset(offset + gestureOffset)
                        
                        // The overlay that shows the crop area
                        Rectangle()
                            .fill(Color.black.opacity(0.5))
                            .reverseMask {
                                Rectangle()
                                    .frame(width: cropFrame.width, height: cropFrame.height)
                            }
                    }
                    .frame(width: editorSize.width, height: editorSize.height)
                    .clipped()
                    .gesture(combinedGesture)
                    
                    Button(role: .destructive) {
                        withAnimation {
                            entry?.backgroundImageData = nil
                            entry?.cropRectData = nil
                        }
                    } label: { Label("Remove Background Image", systemImage: "trash") }
                    .padding()
                    
                } else {
                    // ... The "Add Image" UI ...
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
                            guard let data = try? await newItem?.loadTransferable(type: Data.self) else { return }
                            
                            let entryToUpdate = createOrGetEntry()
                            
                            withAnimation {
                                entryToUpdate.backgroundImageData = data
                                // Reset to a default "center" crop
                                let defaultCrop = CGRect(x: 0, y: 0.125, width: 1, height: 0.75)
                                entryToUpdate.cropRectData = try? JSONEncoder().encode(defaultCrop)
                                setupInitialTransform(from: entryToUpdate, imageSize: UIImage(data: data)?.size ?? .zero)
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
                    Button("Done") {
                        saveCrop()
                        dismiss()
                    }
                }
            }
        }
        .task(id: date) {
            await fetchEntry(for: date)
        }
    }
    
    // --- NEW HELPER FUNCTIONS ---
    
    private func fetchEntry(for date: Date) async {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let predicate = #Predicate<DayEntry> { $0.date == startOfDay }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        do {
            let entries = try modelContext.fetch(descriptor)
            self.entry = entries.first
            if let entry = self.entry, let imageData = entry.backgroundImageData {
                setupInitialTransform(from: entry, imageSize: UIImage(data: imageData)?.size ?? .zero)
            }
        } catch { print("Failed to fetch entry: \(error)") }
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

    private func setupInitialTransform(from entry: DayEntry, imageSize: CGSize) {
        guard imageSize != .zero else { return }
        
        let cropRect: CGRect
        if let data = entry.cropRectData, let decodedRect = try? JSONDecoder().decode(CGRect.self, from: data) {
            cropRect = decodedRect
        } else {
            // Default to a centered crop
            cropRect = CGRect(x: 0, y: 0.125, width: 1.0, height: 0.75)
        }

        let imageAspectRatio = imageSize.width / imageSize.height
        let editorAspectRatio = editorSize.width / editorSize.height
        
        var scaledImageSize = editorSize
        if imageAspectRatio > editorAspectRatio {
            scaledImageSize.height = editorSize.width / imageAspectRatio
        } else {
            scaledImageSize.width = editorSize.height * imageAspectRatio
        }
        
        self.scale = (scaledImageSize.width / cropRect.width) / scaledImageSize.width
        self.offset = CGSize(
            width: -cropRect.midX * scaledImageSize.width * self.scale + editorSize.width / 2,
            height: -cropRect.midY * scaledImageSize.height * self.scale + editorSize.height / 2
        )
    }

    private func saveCrop() {
        guard let entry = entry, let imageSize = (entry.backgroundImageData.flatMap { UIImage(data: $0)?.size }) else { return }
        
        let imageAspectRatio = imageSize.width / imageSize.height
        let editorAspectRatio = editorSize.width / editorSize.height

        var scaledImageSize = editorSize
        if imageAspectRatio > editorAspectRatio {
            scaledImageSize.height = editorSize.width / imageAspectRatio
        } else {
            scaledImageSize.width = editorSize.height * imageAspectRatio
        }
        
        let finalScale = scale * gestureScale
        let finalOffset = offset + gestureOffset
        
        let cropX = (editorSize.width / 2 - finalOffset.width) / (scaledImageSize.width * finalScale)
        let cropY = (editorSize.height / 2 - finalOffset.height) / (scaledImageSize.height * finalScale)
        let cropWidth = cropFrame.width / (scaledImageSize.width * finalScale)
        let cropHeight = cropFrame.height / (scaledImageSize.height * finalScale)
        
        let cropRect = CGRect(
            x: cropX - cropWidth / 2,
            y: cropY - cropHeight / 2,
            width: cropWidth,
            height: cropHeight
        )
        
        entry.cropRectData = try? JSONEncoder().encode(cropRect)
    }
}

// --- ADD THIS HELPER EXTENSION ---
extension View {
    @inlinable
    public func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
}

extension CGSize {
    static func + (lhs: Self, rhs: Self) -> Self {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}
