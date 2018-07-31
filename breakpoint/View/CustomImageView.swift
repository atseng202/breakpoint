//
//  CustomImageView.swift
//  OnTheWay
//
//  Created by Alan Tseng on 3/8/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        //        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        return spinner
    }()
    
    var lastURLUsedToLoadImage: String?
    
    // See instagramFirebase project for previous implementation
    // This one uses an imageCache class instead of a basic dictionary cache
    func loadImage(urlString: String) {
        
        lastURLUsedToLoadImage = urlString
        
        self.image = nil
        
        if let cachedImageTwo = ImageCache.shared.image(forKey: urlString) {
            self.image = cachedImageTwo
//            print("Got image from new class imageCache")
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print("Failed to fetch post image:", error)
                return
            }
            
            if url.absoluteString != self.lastURLUsedToLoadImage { return }
            
            guard let imageData = data else { return }
            
            let photoImage = UIImage(data: imageData)
            
            if photoImage != nil {
                ImageCache.shared.set(photoImage!, forKey: url.absoluteString)
            }
            //            imageCache[url.absoluteString] = photoImage
            
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }
        task.resume()
    }
}

