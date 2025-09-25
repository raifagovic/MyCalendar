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
    var showToolPicker: Bool = false  // <-- new parameter

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

        // Attach PKToolPicker
        if showToolPicker {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let window = windowScene.windows.first {
                    let toolPicker = PKToolPicker.shared(for: window)
                    toolPicker?.setVisible(true, forFirstResponder: canvas)
                    toolPicker?.addObserver(canvas)
                    canvas.becomeFirstResponder()
                }
            }
        }

        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.isUserInteractionEnabled = isEditable

        // Prevent overwriting unsaved work
        if let data = drawingData,
           let drawing = try? PKDrawing(data: data),
           drawing != uiView.drawing {
            uiView.drawing = drawing
        }

        // Update tool picker visibility
        if showToolPicker {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let window = windowScene.windows.first {
                    let toolPicker = PKToolPicker.shared(for: window)
                    toolPicker?.setVisible(true, forFirstResponder: uiView)
                    toolPicker?.addObserver(uiView)
                    uiView.becomeFirstResponder()
                }
            }
        }
    }
}

