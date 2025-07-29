//
//  ImageCropperView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 25. 7. 2025..
//

import SwiftUI

struct ImageCropperView: View {
    let imageData: Data
    
    // Bindings to send the final values back to DayDetailView
    @Binding var scale: CGFloat
    @Binding var offsetX: CGFloat
    @Binding var offsetY: CGFloat

    // State for the current gesture interaction
    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureOffset: CGSize = .zero

    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .updating($gestureScale) { value, state, _ in
                state = value
            }
            .onEnded { value in
                // Update the final scale by multiplying with the gesture's change
                scale *= value
            }

        let dragGesture = DragGesture()
            .updating($gestureOffset) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                // Update the final offset by adding the gesture's translation
                offsetX += value.translation.width
                offsetY += value.translation.height
            }
        
        // Combine both gestures so they can be used simultaneously
        let combinedGesture = SimultaneousGesture(magnificationGesture, dragGesture)

        if let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                // Apply the combined scale (final scale * live gesture scale)
                .scaleEffect(scale * gestureScale)
                // Apply the combined offset
                .offset(x: offsetX + gestureOffset.width, y: offsetY + gestureOffset.height)
                .gesture(combinedGesture) // Attach the combined gesture to the image
        }
    }
}
