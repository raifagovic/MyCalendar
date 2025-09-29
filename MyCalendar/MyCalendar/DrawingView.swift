//
//  DrawingView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 7. 7. 2025..
//

import SwiftUI
import PencilKit

struct DrawingView: UIViewRepresentable {
    @Binding var drawingData: Data?
    var isEditable: Bool
    var showToolPicker: Bool = false

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingView

        init(parent: DrawingView) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawingData = canvasView.drawing.dataRepresentation()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.delegate = context.coordinator
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.drawingPolicy = .anyInput
        canvas.isUserInteractionEnabled = isEditable

        // Restore saved drawing if available
        if let data = drawingData,
           let drawing = try? PKDrawing(data: data) {
            canvas.drawing = drawing
        }

        // Attach PKToolPicker once when the view is created
        if showToolPicker {
            DispatchQueue.main.async {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let toolPicker = PKToolPicker.shared(for: window) {
                    toolPicker.setVisible(true, forFirstResponder: canvas)
                    toolPicker.addObserver(canvas)
                    canvas.becomeFirstResponder()
                }
            }
        }

        return canvas
    }

    // In DrawingView
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.isUserInteractionEnabled = isEditable

        // If there's new data, always update the drawing.
        // The delegate will handle saving changes made by the user.
        if let data = drawingData,
           let drawing = try? PKDrawing(data: data) {
            uiView.drawing = drawing
        } else {
            // If drawingData is nil, clear the canvas.
            uiView.drawing = PKDrawing()
        }
    }
}


