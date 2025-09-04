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
    @FocusState var emojiFieldFocused: Bool   // internal so parent can bind if needed

    var body: some View {
        VStack {
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

                // hidden textfield to trigger keyboard
                TextField("", text: $newEmoji)
                    .focused($emojiFieldFocused)
                    .onChange(of: newEmoji) { _, newValue in
                        if let emoji = newValue.last.map(String.init) {
                            dayEntry.emoticons.append(EmoticonInfo(character: emoji))
                            newEmoji = ""   // reset input but KEEP keyboard open
                        }
                    }
                    .frame(width: 0, height: 0)
                    .opacity(0.01)
            }
        }
        .padding()
        .onAppear {
            emojiFieldFocused = true   // immediately show keyboard
        }
    }
}

