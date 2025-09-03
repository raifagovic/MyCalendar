//
//  EmoticonEditorView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 3. 9. 2025..
//

import SwiftUI

struct EmoticonEditorView: View {
    @Bindable var dayEntry: DayEntry
    
    @State private var newEmoji: String = ""
    @FocusState private var emojiFieldFocused: Bool
    
    var body: some View {
        VStack {
            Text("Edit Emoticons")
                .font(.headline)
            
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.1))
                    .aspectRatio(AppConstants.calendarCellAspectRatio, contentMode: .fit)
                    .overlay(
                        ZStack {
                            ForEach(dayEntry.emoticons) { emoticon in
                                Text(emoticon.character)
                                    .font(.system(size: 32))
                                    .padding(4)
                            }
                        }
                    )
                
                // invisible field triggers emoji keyboard
                TextField("", text: $newEmoji)
                    .focused($emojiFieldFocused)
                    .onChange(of: newEmoji) { _, newValue in
                        if let emoji = newValue.last.map(String.init) {
                            dayEntry.emoticons.append(EmoticonInfo(character: emoji))
                            newEmoji = ""
                            emojiFieldFocused = false
                        }
                    }
                    .frame(width: 0, height: 0)
                    .opacity(0.01)
            }
            
            Button("Add New Emoji") {
                emojiFieldFocused = true
            }
        }
        .padding()
    }
}

