//
//  BlockResource.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/30.
//

import Foundation
import UIKit

// MARK: 分類相關
// 分類色表
let categoryColor =
[UIColor(cgColor: CGColor(red: 250/255, green: 98/255, blue: 104/255, alpha: 1)),
 UIColor(cgColor: CGColor(red: 255/255, green: 193/255, blue: 101/255, alpha: 1)),
 UIColor(cgColor: CGColor(red: 255/255, green: 230/255, blue: 101/255, alpha: 1)),
 UIColor(cgColor: CGColor(red: 13/255, green: 198/255, blue: 172/255, alpha: 1)),
 UIColor(cgColor: CGColor(red: 90/255, green: 161/255, blue: 243/255, alpha: 1)),
 UIColor(cgColor: CGColor(red: 232/255, green: 166/255, blue: 255/255, alpha: 1)),]
// 群組內容的分類圖像名稱
let groupContentCategoryImage = ["", "red", "orange", "yellow", "green", "blue", "purple"]
// 新增方塊的分類圖像名稱
let categoryImage = ["red", "orange", "yellow", "green", "blue", "purple"]
// 分類方塊大小
let categoryBlockSize = CGSize(width: 30, height: 30)

// MARK: 方塊相關
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

// MARK: 版面相關
// 版面一行數量
let boardRowCount = 14
// 版面最小行數
let boardMinRowCount = 30
// 版面空白行數
let boardEmptyRowCount = 10
// 空白方格邊框寬度
let emptyBorderWidth = 0.5
// 塗色方格邊框寬度
let coloredBorderWidth = 1.5


