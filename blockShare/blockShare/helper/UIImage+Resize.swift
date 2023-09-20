//
//  UIImage+Resize.swift
//  helloMyChatroom
//
//  Created by 林裕和 on 2023/8/1.
//

import Foundation
import UIKit

extension UIImage {
    func resize(maxEdge: CGFloat)-> UIImage?{
        
        // check if it is necessary to resize?
        if self.size.width <= maxEdge && self.size.width <= maxEdge {
            return self
        }
        
        // calculate final size with aspect ratio
        let ratio = self.size.width / self.size.height
        let finalSize: CGSize
        if self.size.width > self.size.height{
            let finalHeight = maxEdge / ratio
            finalSize = CGSize(width: maxEdge, height: finalHeight)
        }else{
            // height >= width
            let finalWidth = maxEdge * ratio
            finalSize = CGSize(width: finalWidth, height: maxEdge)
        }
        
        // Export as UIImage
        UIGraphicsBeginImageContext(finalSize)
        let rect = CGRect(origin: .zero, size: finalSize)
        self.draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
