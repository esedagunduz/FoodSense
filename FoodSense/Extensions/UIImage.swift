//
//  UIImage.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 27.01.2026.
//

import Foundation
import UIKit
extension UIImage {
    func optimizedImageData() -> Data? {
        let maxDimension: CGFloat = 1024
        let compressionQuality: CGFloat = 0.5 
        
        let size = self.size
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        
        if ratio >= 1.0 {
            return self.jpegData(compressionQuality: compressionQuality)
        }
        
        let newSize = CGSize(
            width: size.width * ratio,
            height: size.height * ratio
        )
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resized.jpegData(compressionQuality: compressionQuality)
    }
    
    func optimizedForAPI(maxSize: CGFloat = 768) -> UIImage? {
        let size = self.size
        let compressionQuality: CGFloat = 0.6
        let ratio = min(maxSize / size.width, maxSize / size.height)
        
        if ratio >= 1.0 {
            guard let data = self.jpegData(compressionQuality: compressionQuality) else { return nil }
            return UIImage(data: data)
        }

        let newSize = CGSize(
            width: size.width * ratio,
            height: size.height * ratio
        )
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        guard let data = resized.jpegData(compressionQuality: compressionQuality) else { return resized }
        return UIImage(data: data)
    }
}
