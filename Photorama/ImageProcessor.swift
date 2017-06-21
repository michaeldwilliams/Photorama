//
//  ImageProcessor.swift
//  Photorama
//
//  Created by Michael Williams on 6/20/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ImageProcessor {

    enum Action {
        case scale(maxSize: CGSize)
        case pixellateFaces
    }
    
    enum Filter {
        case none
        case gloom(intensity: Double, radius: Double)
        case sepia(intensity: Double)
        case blur(radius: Double)
    }
    
    enum Error: Swift.Error {
        case incompatibleImage
    }
    
    func perform(_ actions: [Action], on image: UIImage) throws -> UIImage {
        guard var workingImage = CIImage(image: image) else {
            throw Error.incompatibleImage
        }
        let context = CIContext(options: nil)
        
        for action in actions {
            switch action {
            case .pixellateFaces:
                workingImage = workingImage.pixellatedFaces()
            case .scale(let maxSize):
                workingImage = workingImage.scaled(toFit: maxSize)
            }
        }
        
        let renderedImage = context.createCGImage(workingImage, from: (workingImage.extent))!
        let resultImage = UIImage(cgImage: renderedImage)
        return resultImage
    }
}
