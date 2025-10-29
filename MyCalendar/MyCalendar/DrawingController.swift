//
//  DrawingController.swift
//  MyCalendar
//
//  Created by Raif Agovic on 29. 10. 2025..
//

import SwiftUI // Import SwiftUI for @Published
import PencilKit


import SwiftUI // Import SwiftUI for @Published
import PencilKit

final class DrawingController: ObservableObject {
    weak var canvas: PKCanvasView? {
        didSet {
            // When canvas is set, ensure its initial interaction state
            canvas?.isUserInteractionEnabled = _isDrawing
            // Also, if the canvas changes, ensure tool picker state is applied.
            // This is crucial if the canvas view is recreated for some reason.
            if _isDrawing {
                ensureShowToolPickerWithRetry()
            } else {
                hideToolPicker()
            }
        }
    }

    // New: Internal state to control drawing interaction and tool picker.
    // DayDetailView will bind to this, and this controller will react.
    @Published var _isDrawing: Bool = false {
        didSet {
            canvas?.isUserInteractionEnabled = _isDrawing
            if _isDrawing {
                ensureShowToolPickerWithRetry()
            } else {
                hideToolPicker()
            }
        }
    }

    private var hasAddedObserver = false

    /// Attempt to show tool picker and make canvas first responder.
    /// Returns true if succeeded.
    func showToolPicker() -> Bool {
        guard let canvas = canvas, let window = canvas.window else { return false }
        guard let toolPicker = PKToolPicker.shared(for: window) else { return false }

        // Only add observer if not already added
        if !hasAddedObserver {
            toolPicker.addObserver(canvas)
            hasAddedObserver = true
        }
        
        // Ensure visibility and first responder status
        toolPicker.setVisible(true, forFirstResponder: canvas)
        let becameResponder = canvas.becomeFirstResponder()
        
        return becameResponder
    }

    /// Hide the tool picker and remove observer if needed.
    func hideToolPicker() {
        guard let canvas = canvas, let window = canvas.window else {
            // If window not available, still clear flag so we re-add later if needed.
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
