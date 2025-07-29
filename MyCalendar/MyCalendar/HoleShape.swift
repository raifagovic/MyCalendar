//
//  HoleShape.swift
//  MyCalendar
//
//  Created by Raif Agovic on 29. 7. 2025..
//

import SwiftUI

// This Shape creates a rectangle with a cutout in the center.
struct HoleShape: Shape {
    let rect: CGRect // The size of the hole to cut out

    func path(in bounds: CGRect) -> Path {
        var path = Rectangle().path(in: bounds) // Start with the full outer rectangle

        // Define the path for the inner cutout rectangle
        let holePath = Rectangle().path(in: rect)
        
        // Add the cutout path to the main path
        path.addPath(holePath)
        
        return path
    }
}
