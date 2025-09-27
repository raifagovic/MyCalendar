//
//  Drawinginfo.swift
//  MyCalendar
//
//  Created by Raif Agovic on 27. 9. 2025..
//

import Foundation
import SwiftData
import CoreGraphics

@Model
final class DrawingInfo: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var drawingData: Data?   // PencilKit PKDrawing archived to Data

    // Normalized position (0..1)
    var posX: CGFloat = 0.5
    var posY: CGFloat = 0.5
    var scale: CGFloat = 1.0

    // Rotation stored as degrees
    var rotationDegrees: Double = 0.0

    // Link to parent
    var dayEntry: DayEntry?

    init(drawingData: Data? = nil) {
        self.drawingData = drawingData
    }
}

