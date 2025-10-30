//
//  CanvasHostView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 30. 10. 2025..
//

import UIKit
import PencilKit

/// A wrapper view that hosts a PKCanvasView and notifies DrawingController
/// when the canvas enters the window (so PKToolPicker can attach properly).
final class CanvasHostView: UIView {
    let canvasView: PKCanvasView = PKCanvasView()
    weak var controller: DrawingController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // Add and constrain the canvas
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: trailingAnchor),
            canvasView.topAnchor.constraint(equalTo: topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Appearance
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        // Notify controller that the canvas is in the window
        if let controller = controller {
            controller.canvas = canvasView
            if controller._isDrawing {
                DispatchQueue.main.async {
                    controller.ensureShowToolPickerWithRetry()
                }
            }
        }
    }
}
