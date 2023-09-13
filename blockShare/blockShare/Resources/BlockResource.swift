//
//  BlockResource.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/30.
//

import Foundation
import UIKit

// 分類色表
let categoryColor = [UIColor.blue,UIColor.red,UIColor.green,UIColor.orange,UIColor.purple,UIColor.yellow]
// 方塊大小
let squareSize: CGFloat = 25
// 方塊類型
enum BlockType: CaseIterable{
    case IBlock
    case leftZBlock
    case rightZBlock
    case leftLBlock
    case rightLBlock
    case squareBlock
    case TBlock
    
    static func random<G: RandomNumberGenerator>(using generator: inout G) -> BlockType {
            return BlockType.allCases.randomElement(using: &generator)!
        }
    
    static func random() -> BlockType {
            var g = SystemRandomNumberGenerator()
            return BlockType.random(using: &g)
        }
}

// 順逆時針
enum RotateDirection{
    case clockWise
    case counterClockWise
}
