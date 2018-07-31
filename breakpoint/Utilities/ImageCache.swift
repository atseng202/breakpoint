//
//  ImageCache.swift
//  OnTheWay
//
//  Created by Alan Tseng on 4/28/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit


class ImageCache {
    
    private static let _shared = ImageCache()
    
    var images = [String:UIImage]()
    
    static var shared: ImageCache {
        return _shared
    }
    
    init() {
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidReceiveMemoryWarning, object: nil, queue: .main) { [weak self] (notification) in
            self?.images.removeAll(keepingCapacity: false)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - Custom Accessors
extension ImageCache {
    
    func set(_ image: UIImage, forKey key: String) {
        images[key] = image
    }
    
    func image(forKey key: String) -> UIImage? {
        return images[key]
    }
}
