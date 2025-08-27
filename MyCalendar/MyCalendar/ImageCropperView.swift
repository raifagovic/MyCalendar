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
        // These gesture definitions are still necessary.
        let magnificationGesture = MagnificationGesture()
            .updating($gestureScale) { value, state, _ in
                state = value
            }
            .onEnded { value in
                scale *= value
            }

        let dragGesture = DragGesture()
            .updating($gestureOffset) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                offsetX += value.translation.width
                offsetY += value.translation.height
            }
        
        let combinedGesture = SimultaneousGesture(magnificationGesture, dragGesture)

        // The change is to wrap the Image in a ZStack and apply the gesture to the ZStack.
        ZStack {
            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(scale * gestureScale)
                    .offset(x: offsetX + gestureOffset.width, y: offsetY + gestureOffset.height)
            }
        }
        .gesture(combinedGesture) // Apply the gesture to the ZStack container
    }
}
