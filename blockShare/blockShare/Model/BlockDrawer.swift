//
//  BlockDrawer.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/31.
//

import Foundation
import UIKit

class BlockDrawer{
    static let squarePadding: CGFloat = 0.4
    
    static func drawSquare(x: CGFloat, y: CGFloat, squareSize: CGFloat, color: UIColor) -> UIView{
        let viewRectFrame = CGRect(x: x + squarePadding, y: y + squarePadding, width: squareSize - squarePadding, height: squareSize - squarePadding)
        let squareView = UIView(frame: viewRectFrame)
        squareView.backgroundColor = color
        squareView.layer.borderWidth = 1
        squareView.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        squareView.layer.cornerRadius = 5
        squareView.alpha = CGFloat(1.0)
        return squareView
    }
}
