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

    @Query private var entries: [DayEntry]
    @State private var selectedPhoto: PhotosPickerItem?
    
    @State private var currentScale: CGFloat = 1.0
    @State private var currentOffsetX: CGFloat = 0.0
    @State private var currentOffsetY: CGFloat = 0.0

    init(date: Date) {
        self.date = date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        _entries = Query(filter: #Predicate<DayEntry> { $0.date == startOfDay })
    }

    var body: some View {
        let entry = entries.first ?? createAndReturnEntry()

        NavigationStack {
            VStack {
                if let imageData = entry.backgroundImageData {
                    // --- THE NEW, CONTAINED, "WHATSAPP STYLE" CROPPER ---
                    
                    Text("Pan and pinch to frame your image")
                        .font(.headline)
                        .padding(.top)

                    // We use GeometryReader to get the available size for our editor.
                    GeometryReader { geometry in
                        // Define the size of our transparent "hole" based on the aspect ratio.
                        // We make it 80% of the available width to leave some space.
                        let viewportWidth = geometry.size.width * 0.8
                        let viewportHeight = viewportWidth / AppConstants.calendarCellAspectRatio
                        
                        // Center the viewport within the available geometry.
                        let viewportRect = CGRect(
                            x: (geometry.size.width - viewportWidth) / 2,
                            y: (geometry.size.height - viewportHeight) / 2,
                            width: viewportWidth,
                            height: viewportHeight
                        )

                        ZStack {
                            // Layer 1: The interactive image. It sits at the bottom.
                            ImageCropperView(
                                imageData: imageData,
                                scale: $currentScale,
                                offsetX: $currentOffsetX,
                                offsetY: $currentOffsetY
                            )

                            // Layer 2: The Dimming Overlay. We use our custom HoleShape.
                            // The .evenOdd fill style is what makes the hole transparent.
                            HoleShape(rect: viewportRect)
                                .fill(Color.black.opacity(0.6), style: FillStyle(eoFill: true))

                            // Layer 3: The White Border. We draw this separately for clarity.
                            Rectangle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: viewportWidth, height: viewportHeight)
                        }
                    }
                    // Give the entire editor a reasonable, fixed height.
                    // It will NOT take over the whole screen.
                    .frame(height: 400)
                    .padding(.horizontal)

                    // --- REMOVE BUTTON ---
                    Button(role: .destructive) {
                        withAnimation {
                            entry.backgroundImageData = nil
                            entry.backgroundImageScale = 1.0
                            entry.backgroundImageOffsetX = 0
                            entry.backgroundImageOffsetY = 0
                        }
                    } label: {
                        Label("Remove Background Image", systemImage: "trash")
                    }
                    .padding()

                } else {
                    // PhotosPicker to add an image... (this part remains the same)
                    Spacer()
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Add Background Image", systemImage: "photo")
                    }
                    .onChange(of: selectedPhoto) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                withAnimation {
                                    entry.backgroundImageData = data
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
                .navigationTitle("Edit Day")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Done button to dismiss the view
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                // Load the saved crop data when the view appears
                currentScale = entry.backgroundImageScale
                currentOffsetX = entry.backgroundImageOffsetX
                currentOffsetY = entry.backgroundImageOffsetY
            }
            .onDisappear {
                // Save the final crop data when the view is dismissed
                entry.backgroundImageScale = currentScale
                entry.backgroundImageOffsetX = currentOffsetX
                entry.backgroundImageOffsetY = currentOffsetY
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
