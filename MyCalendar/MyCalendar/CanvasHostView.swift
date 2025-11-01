//
//  CanvasHostView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 30. 10. 2025..
//

//import UIKit
//import PencilKit
//
///// A wrapper view that hosts a PKCanvasView and notifies DrawingController
///// when the canvas enters the window (so PKToolPicker can attach properly).
//final class CanvasHostView: UIView {
//    let canvasView: PKCanvasView = PKCanvasView()
//    weak var controller: DrawingController?
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setup()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setup()
//    }
//
//    private func setup() {
//        // Add and constrain the canvas
//        canvasView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(canvasView)
//        NSLayoutConstraint.activate([
//            canvasView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            canvasView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            canvasView.topAnchor.constraint(equalTo: topAnchor),
//            canvasView.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//
//        // Appearance
//        canvasView.backgroundColor = .clear
//        canvasView.isOpaque = false
//        canvasView.drawingPolicy = .anyInput
//    }
//
//    override func didMoveToWindow() {
//        super.didMoveToWindow()
//
//        // Notify controller that the canvas is in the window
//        if let controller = controller {
//            controller.canvas = canvasView
//            if controller._isDrawing {
//                DispatchQueue.main.async {
//                    controller.ensureShowToolPickerWithRetry()
//                }
//            }
//        }
//    }
//}

import UIKit
import PencilKit

final class CanvasHostView: UIView {
    let canvasView = PKCanvasView()
    weak var controller: DrawingController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCanvas()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCanvas()
    }

    private func setupCanvas() {
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(canvasView)

        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: trailingAnchor),
            canvasView.topAnchor.constraint(equalTo: topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let controller = controller else { return }

        controller.canvas = canvasView

        // When the view enters a window and drawing mode is active, show picker
        if controller.isDrawing {
            controller.showToolPickerAfterWindow()
        }
    }
}
