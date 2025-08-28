//
//  Image+Crop.swift
//  MyCalendar
//
//  Created by Raif Agovic on 28. 8. 2025..
//

import UIKit

extension UIImage {
    func cropped(to rect: CGRect, scale: CGFloat = 1.0) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let scaledRect = CGRect(x: rect.origin.x * self.scale,
                                y: rect.origin.y * self.scale,
                                width: rect.size.width * self.scale,
                                height: rect.size.height * self.scale)
        
        guard let croppedCGImage = cgImage.cropping(to: scaledRect) else { return nil }
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
}

