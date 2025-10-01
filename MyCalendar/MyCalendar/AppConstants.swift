//
//  AppConstants.swift
//  MyCalendar
//
//  Created by Raif Agovic on 28. 7. 2025..
//

import Foundation
import CoreGraphics

struct AppConstants {
    
    static let stickerEmojiBaseFontSize: CGFloat = 24
    static let stickerTextBaseFontSize: CGFloat = 12

    // The aspect ratio of a calendar cell (width ÷ height).
    static let calendarCellAspectRatio: CGFloat = 0.5   // measured in DayCellView
    
    // Width of the editor preview in DayDetailView.
    static let editorPreviewWidth: CGFloat = 300
    
    // Height automatically derived from the aspect ratio.
    static var editorPreviewHeight: CGFloat {
        editorPreviewWidth / calendarCellAspectRatio
    }
}
