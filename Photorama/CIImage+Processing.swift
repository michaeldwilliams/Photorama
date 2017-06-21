//
//  CIImage+Processing.swift
//  Photorama
//
//  Created by Michael Williams on 6/20/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Foundation
import CoreImage

extension CIImage {
    func scaled(toFit maxSize: CGSize) -> CIImage {
        let aspectRatio = extent.width / extent.height
        let scale: CGFloat
        
        if aspectRatio > 1.0 {
            scale = maxSize.width / extent.width
        } else {
            scale = maxSize.height / extent.height
        }
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        let outputImage = applying(scaleTransform)
        return outputImage
    }
    
    
    func pixellatedFaces() -> CIImage {
        return self
    }
}
