//
//  DayDetailView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 23. 7. 2025..
//

import SwiftUI
import SwiftData

struct DayDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var dayEntry: DayEntry
    
    @State private var selectedStickerID: PersistentIdentifier?
    @State private var newText: String = ""
    
    var body: some View {
        VStack {
            // Canvas for stickers + background
            GeometryReader { geometry in
                let w = geometry.size.width
                let h = geometry.size.height
                
                ZStack {
                    // Background image if set
                    if let imageData = dayEntry.backgroundImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(dayEntry.backgroundImageScale)
                            .offset(
                                x: dayEntry.backgroundImageOffsetX * w,
                                y: dayEntry.backgroundImageOffsetY * h
                            )
                            .frame(width: w, height: h)
                            .clipped()
                    } else {
                        Color.black.opacity(0.05)
                    }
                    
                    // Stickers (text & emoji)
                    ForEach(dayEntry.stickers) { sticker in
                        StickerView(
                            sticker: binding(for: sticker),
                            isSelected: Binding(
                                get: { selectedStickerID == sticker.persistentModelID },
                                set: { newValue in
                                    selectedStickerID = newValue ? sticker.persistentModelID : nil
                                }
                            ),
                            containerSize: CGSize(width: w, height: h)
                        )
                    }
                }
            }
            .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit)
            
            Divider()
            
            // Input for adding new text/emoji stickers
            HStack {
                TextField("Add text or emoji…", text: $newText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Add") {
                    addTextSticker(newText)
                    newText = ""
                }
                .disabled(newText.isEmpty)
            }
            .padding()
        }
        .navigationTitle(dayEntry.date.formatted(date: .abbreviated, time: .omitted))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    try? modelContext.save()
                }
            }
        }
    }
    
    // MARK: - Sticker Helpers
    
    private func binding(for sticker: StickerInfo) -> Binding<StickerInfo> {
        guard let index = dayEntry.stickers.firstIndex(where: { $0.persistentModelID == sticker.persistentModelID }) else {
            fatalError("Sticker not found in dayEntry")
        }
        return $dayEntry.stickers[index]
    }
    
    private func addTextSticker(_ text: String) {
        guard !text.isEmpty else { return }
        let sticker = StickerInfo(type: .text, content: text)
        // Start in center with normalized coordinates
        sticker.posX = 0.5
        sticker.posY = 0.5
        sticker.scale = 1.0
        dayEntry.stickers.append(sticker)
        try? modelContext.save()
    }
}




