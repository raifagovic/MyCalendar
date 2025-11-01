//
//  DrawingView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 7. 7. 2025..
//

//import SwiftUI
//import PencilKit
//
//struct DrawingView: UIViewRepresentable {
//    @ObservedObject var controller: DrawingController
//    @Binding var drawingData: Data?
//
//    func makeUIView(context: Context) -> UIView {
//        let host = CanvasHostView(frame: .zero)
//        host.controller = controller
//
//        let canvas = host.canvasView
//        canvas.delegate = context.coordinator
//
//        controller.canvas = canvas
//
//        // If drawing mode is already active, try showing tool picker
//        if controller._isDrawing {
//            DispatchQueue.main.async {
//                controller.ensureShowToolPickerWithRetry()
//            }
//        }
//
//        return host
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {
//        guard let host = uiView as? CanvasHostView else { return }
//        let canvas = host.canvasView
//        controller.canvas = canvas
//        canvas.delegate = context.coordinator
//
//        if let data = drawingData,
//           let drawing = try? PKDrawing(data: data),
//           drawing != canvas.drawing {
//            canvas.drawing = drawing
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self)
//    }
//
//    class Coordinator: NSObject, PKCanvasViewDelegate {
//        var parent: DrawingView
//        init(parent: DrawingView) { self.parent = parent }
//        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
//            parent.drawingData = canvasView.drawing.dataRepresentation()
//        }
//    }
//}

import SwiftUI
import PencilKit

struct DrawingView: UIViewRepresentable {
    @ObservedObject var controller: DrawingController
    @Binding var drawingData: Data?

    func makeUIView(context: Context) -> CanvasHostView {
        let host = CanvasHostView()
        host.controller = controller

        host.canvasView.delegate = context.coordinator
        controller.canvas = host.canvasView

        return host
    }

    func updateUIView(_ host: CanvasHostView, context: Context) {
        controller.canvas = host.canvasView

        if let data = drawingData,
           let drawing = try? PKDrawing(data: data),
           drawing != host.canvasView.drawing {
            host.canvasView.drawing = drawing
        }

        host.canvasView.delegate = context.coordinator
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingView
        init(_ parent: DrawingView) { self.parent = parent }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawingData = canvasView.drawing.dataRepresentation()
        }
    }
}
