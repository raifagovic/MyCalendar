//
//  DrawingView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 7. 7. 2025..
//

import SwiftUI
import PencilKit

struct DrawingView: UIViewRepresentable {
    @ObservedObject var controller: DrawingController
    @Binding var drawingData: Data?

    func makeUIView(context: Context) -> PKCanvasView {
            let canvas = PKCanvasView()
            controller.canvas = canvas // Link the controller to the canvas
            canvas.backgroundColor = .clear
            canvas.isOpaque = false
            canvas.drawingPolicy = .anyInput
            canvas.delegate = context.coordinator
            
//            // Initial setup for editable state (controlled by the controller's _isDrawing)
//            canvas.isUserInteractionEnabled = controller._isDrawing
//            
//            // Crucial: When the view is created, if drawing mode is active,
//            // tell the controller to show the tool picker.
//            if controller._isDrawing {
//                controller.ensureShowToolPickerWithRetry()
//            }
            return canvas
        }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
            // DrawingView now solely reacts to changes in drawingData.
            // The `isUserInteractionEnabled` and `PKToolPicker` visibility
            // are managed by the DrawingController via its `_isDrawing` property's `didSet`.
            
            if let data = drawingData,
               let drawing = try? PKDrawing(data: data),
               drawing != canvas.drawing {
                canvas.drawing = drawing
            }
            
            // The controller's _isDrawing didSet will handle tool picker visibility
            // and responder status, and also canvas.isUserInteractionEnabled.
            // So, this updateUIView only needs to ensure the canvas is correctly linked
            // and its drawing content is up to date.
        }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingView
        init(parent: DrawingView) { self.parent = parent }
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawingData = canvasView.drawing.dataRepresentation()
        }
    }
}
