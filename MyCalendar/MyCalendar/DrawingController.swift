//
//  DrawingController.swift
//  MyCalendar
//
//  Created by Raif Agovic on 29. 10. 2025..
//

import SwiftUI // Import SwiftUI for @Published
import PencilKit


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
