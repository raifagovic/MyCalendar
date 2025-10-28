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
    var canvas: PKCanvasView?
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
