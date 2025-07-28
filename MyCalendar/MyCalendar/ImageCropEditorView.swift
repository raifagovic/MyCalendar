//
//  ImageCropEditorView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 28. 7. 2025..
//

import SwiftUI

struct ImageCropEditorView: View {
    let imageData: Data
    
    // Bindings to the data source
    @Binding var scale: CGFloat
    @Binding var offsetX: CGFloat
    @Binding var offsetY: CGFloat
    
    // The aspect ratio for the viewport
    let aspectRatio = AppConstants.calendarCellAspectRatio

    var body: some View {
        VStack {
            // THE CROPPER COMPONENT
            ZStack {
                // Layer 1: The interactive image (moves underneath)
                ImageCropperView(
                    imageData: imageData,
                    scale: $scale,
                    offsetX: $offsetX,
                    offsetY: $offsetY
                )
                
                // Layer 2: The overlay with the clear "hole"
                GeometryReader { geometry in
                    // This is the blurred/dimmed part
                    Rectangle()
                        .fill(.black.opacity(0.6))
                        .blur(radius: 3)
                        
                        // We use a mask to cut out the clear viewport
                        .mask(
                            // The mask itself
                            ZStack {
                                // Full rectangle
                                Rectangle()
                                    .fill(Color.white)
                                
                                // The "hole"
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: geometry.size.width, height: geometry.size.width / aspectRatio)
                            }
                            .compositingGroup()
                            .luminanceToAlpha() // Makes black transparent in the mask
                        )
                    
                    // Layer 3: The border for the viewport
                    Rectangle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: geometry.size.width, height: geometry.size.width / aspectRatio)
                }
            }
            .frame(height: 300) // Give the editor a fixed, manageable height
            .cornerRadius(15)
            .clipped()

            // THE ZOOM SLIDER
            HStack {
                Image(systemName: "minus.magnifyingglass")
                Slider(value: $scale, in: 1.0...5.0) // Zoom from 1x to 5x
                Image(systemName: "plus.magnifyingglass")
            }
            .padding(.top, 10)
        }
    }
}
