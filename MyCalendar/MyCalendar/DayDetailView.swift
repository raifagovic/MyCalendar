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
            
            NavigationStack { // Use a NavigationStack for a toolbar
                VStack {
                    if let imageData = entry.backgroundImageData {
                        VStack {
                            Text("Pan and pinch to frame your image")
                                .font(.headline)
                                .padding(.top)
                            
                            // The "viewport" for our cropper
                            ZStack {
                                // The interactive cropper view
                                ImageCropperView(
                                    imageData: imageData,
                                    scale: $currentScale,
                                    offsetX: $currentOffsetX,
                                    offsetY: $currentOffsetY
                                )
                            }
                            .frame(height: 250) // The size of the crop window
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                            .padding(.horizontal)
                            
                            // --- REMOVE BUTTON ---
                            Button(role: .destructive) {
                                withAnimation {
                                    entry.backgroundImageData = nil
                                    // Reset crop data when image is removed
                                    entry.backgroundImageScale = 1.0
                                    entry.backgroundImageOffsetX = 0
                                    entry.backgroundImageOffsetY = 0
                                }
                            } label: {
                                Label("Remove Background Image", systemImage: "trash")
                            }
                            .padding()
                        }
                    } else {
                        // PhotosPicker to add an image
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
                    }
                    
                    Spacer()
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
