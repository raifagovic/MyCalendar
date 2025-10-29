//
//  DrawingView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 7. 7. 2025..
//

import SwiftUI
import PencilKit

//struct DrawingView: UIViewRepresentable {
//    @Binding var drawingData: Data?
//    var isEditable: Bool
//    var showToolPicker: Bool
//
//    class Coordinator: NSObject, PKCanvasViewDelegate {
//        var parent: DrawingView
//        init(parent: DrawingView) { self.parent = parent }
//
//        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
//            parent.drawingData = canvasView.drawing.dataRepresentation()
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self)
//    }
//
//    func makeUIView(context: Context) -> PKCanvasView {
//        let canvas = PKCanvasView()
//        canvas.delegate = context.coordinator
//        canvas.backgroundColor = .clear
//        canvas.isOpaque = false
//        canvas.drawingPolicy = .anyInput
//        canvas.isUserInteractionEnabled = isEditable
//
//        // Restore saved drawing
//        if let data = drawingData,
//           let drawing = try? PKDrawing(data: data) {
//            canvas.drawing = drawing
//        }
//
//        return canvas
//    }
//
//    func updateUIView(_ canvas: PKCanvasView, context: Context) {
//        canvas.isUserInteractionEnabled = isEditable
//
//        // Sync drawing content if changed externally
//        if let data = drawingData,
//           let drawing = try? PKDrawing(data: data),
//           drawing != canvas.drawing {
//            canvas.drawing = drawing
//        }
//
//        // ✅ Handle showing/hiding the tool picker
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let window = windowScene.windows.first,
//           let toolPicker = PKToolPicker.shared(for: window) {
//            
//            if showToolPicker {
//                toolPicker.setVisible(true, forFirstResponder: canvas)
//                toolPicker.addObserver(canvas)
//                DispatchQueue.main.async {
//                    canvas.becomeFirstResponder()
//                }
//            } else {
//                toolPicker.setVisible(false, forFirstResponder: canvas)
//                toolPicker.removeObserver(canvas)
//                DispatchQueue.main.async {
//                    canvas.resignFirstResponder()
//                }
//            }
//        }
//    }
//}

final class DrawingController: ObservableObject {
    weak var canvas: PKCanvasView?
    private var hasAddedObserver = false

    /// Attempt to show tool picker and make canvas first responder.
    /// Returns true if succeeded.
    func showToolPicker() -> Bool {
        guard let canvas = canvas, let window = canvas.window else { return false }
        guard let toolPicker = PKToolPicker.shared(for: window) else { return false }

        if !hasAddedObserver {
            toolPicker.addObserver(canvas)
            hasAddedObserver = true
        }
        toolPicker.setVisible(true, forFirstResponder: canvas)
        let became = canvas.becomeFirstResponder()
        return became
    }

    /// Hide the tool picker and remove observer if needed.
    func hideToolPicker() {
        guard let canvas = canvas, let window = canvas.window else {
            // If window not available, still clear flag so we re-add later
            hasAddedObserver = false
            return
        }
        if let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(false, forFirstResponder: canvas)
            if hasAddedObserver {
                toolPicker.removeObserver(canvas)
                hasAddedObserver = false
            }
        }
        canvas.resignFirstResponder()
    }

    /// Try show with a short retry (safe, idempotent)
    func ensureShowToolPickerWithRetry(retryDelay: TimeInterval = 0.05) {
        // First try now
        if showToolPicker() { return }

        // Small retry after a short delay to let responder chain settle
        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) { [weak self] in
            _ = self?.showToolPicker()
        }
    }
}

struct DrawingView: UIViewRepresentable {
    @ObservedObject var controller: DrawingController
    @Binding var drawingData: Data?
    var isEditable: Bool
    var showToolPicker: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        controller.canvas = canvas
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.drawingPolicy = .anyInput
        canvas.delegate = context.coordinator
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        canvas.isUserInteractionEnabled = isEditable

        if let data = drawingData,
           let drawing = try? PKDrawing(data: data),
           drawing != canvas.drawing {
            canvas.drawing = drawing
        }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let toolPicker = PKToolPicker.shared(for: window) else { return }

        if showToolPicker {
            toolPicker.setVisible(true, forFirstResponder: canvas)
            toolPicker.addObserver(canvas)
            canvas.becomeFirstResponder()
        } else {
            toolPicker.setVisible(false, forFirstResponder: canvas)
            toolPicker.removeObserver(canvas)
            canvas.resignFirstResponder()
        }
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
