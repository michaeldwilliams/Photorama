//
//  ThumbnailStore.swift
//  Photorama
//
//  Created by Michael Williams on 6/21/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Foundation
import UIKit

class ThumbnailStore {
    
    private let thumbnailCache = NSCache<NSString,UIImage>()
    
    func thumbnail(forKey key: NSString) -> UIImage? {
        return thumbnailCache.object(forKey: key)
    }
    
    func setThumbnail(image: UIImage, forKey key: NSString) {
        thumbnailCache.setObject(image, forKey: key)
    }
    
    func clearThumbnails() {
        thumbnailCache.removeAllObjects()
    }
    
}
