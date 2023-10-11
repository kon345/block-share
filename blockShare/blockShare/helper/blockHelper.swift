//
//  blockHelper.swift
//  blockShare
//
//  Created by 林裕和 on 2023/9/14.
//

import Foundation
import UIKit
import SwiftLinkPreview

struct BlockID: Codable{
    var blockID: Int
}

struct BlockData: Codable {
    var blockID: Int
    var blockContent: String
    var blockCategoryIndex: Int
    var blockPosition: [[Int]]
    
    private enum CodingKeys: String, CodingKey {
        case blockID
        case blockContent
        case blockCategoryIndex
        case blockPosition
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        blockID = try container.decode(Int.self, forKey: .blockID)
        blockContent = try container.decode(String.self, forKey: .blockContent)
        blockCategoryIndex = try container.decode(Int.self, forKey: .blockCategoryIndex)
        
        // Decode the nested JSON string for blockPosition
        let blockPositionString = try container.decode(String.self, forKey: .blockPosition)
        // Convert the JSON string to Data
        if let blockPositionData = blockPositionString.data(using: .utf8) {
            // Decode the Data to [Position]
            blockPosition = try JSONDecoder().decode([[Int]].self, from: blockPositionData)
        } else {
            // Handle the case where conversion to Data fails
            throw DecodingError.dataCorruptedError(
                forKey: .blockPosition,
                in: container,
                debugDescription: "Failed to convert blockPositionString to Data."
            )
        }
    }
}

class blockHelper{
    private let blockContentKey = "blockContent"
    private let blockCategoryIndexKey = "blockCategoryIndex"
    private let blockPositionKey = "blockPosition"
    private let groupIDKey = "groupID"
    private let blockIDKey = "blockID"
    private let createBlockURL = "http://localhost:8888/blockShare/createBlock.php"
    private let getBlockAfterIDURL = "http://localhost:8888/blockShare/getBlockAfterID.php"
    
    static let shared = blockHelper()
    private init(){}
    
    let slp = SwiftLinkPreview(cache: InMemoryCache())
    
    // 所有方塊資料
    var BlockListData: [BlockData] = []
    
    // 新增方塊資料
    var isNewBlockCreated = false
    var newBlockContent: String = ""
    var newBlockCategoryIndex: Int = -1
    var newBlockPosition = [[Int]]()
    
    // 重置新方塊資料
    func resetNewBlockData(){
        isNewBlockCreated = false
        newBlockContent = ""
        newBlockCategoryIndex = -1
        newBlockPosition = []
    }
    
    // 創建新方塊
    // @param blockContent
    // @param blockCategoryIndex
    // @param groupID
    func createBlock(blockContent:String, blockCategoryIndex:Int, blockPosition: [[Int]], groupID: Int, completion: @escaping DoneHandler<BlockID>){
        let parameters : [String : Any] = [blockContentKey: blockContent, blockCategoryIndexKey: blockCategoryIndex, blockPositionKey: blockPosition, groupIDKey: groupID]
        Communicator.shared.doPost(createBlockURL,parameters: parameters, completion: completion)
    }
    
    // 取得方塊ID後的所有方塊
    // @param groupID
    // @param blockID
    func getBlockList(groupID:Int, blockID:Int, completion: @escaping DoneHandler<[BlockData]>){
        let parameters : [String : Any] = [groupIDKey: groupID, blockIDKey: blockID]
        Communicator.shared.doGet(getBlockAfterIDURL, parameters: parameters, completion: completion)
    }
    
    // 創建隨機種類方塊
    // @param color
    // @param position
    func createRandomBlock(color: UIColor, position: CGPoint) -> basicBlock{
        let blockType = BlockType.random()
        switch blockType{
        case .IBlock:
            return IBlock(color: color, startPosition: position)
        case .TBlock:
            return TBlock(color: color, startPosition: position)
        case .leftLBlock:
            return leftLBlock(color: color, startPosition: position)
        case .leftZBlock:
            return leftZBlock(color: color, startPosition: position)
        case .rightLBlock:
            return rightLBlock(color: color, startPosition: position)
        case .rightZBlock:
            return rightZBlock(color: color, startPosition: position)
        case .squareBlock:
            return SquareBlock(color: color, startPosition: position)
        }
    }
    
    // 取得所有方塊最大列數
    func getBlockMaxRow() -> Int{
        var maxRow = 0
        BlockListData.forEach { blockData in
            blockData.blockPosition.forEach { position in
                if position[1] > maxRow{
                    maxRow = position[1]
                }
            }
        }
        return maxRow
    }
    
    // 給位置(IndexPath.row)取得blockData
    // ＠param indexPathRow
    func findBlock(indexPathRow: Int) -> BlockData?{
        var targetBlockData: BlockData? = nil
        BlockListData.forEach { blockData in
            let blockPositionIndexPath: [Int] = blockData.blockPosition.map { position in
                return ((position[1]-1) * boardRowCount + (position[0] - 1))
            }
            if blockPositionIndexPath.contains(indexPathRow){
                targetBlockData = blockData
            }
        }
        return targetBlockData
    }
    
    // 取得所有非當前分類的方塊的位置(IndexPath.row)
    // @param currentCategoryIndex
    func getOtherCategoryBlockPositions(currentCategoryIndex: Int) -> [Int]{
        var otherCategoryBlockIndexPathList: [Int] = []
        if currentCategoryIndex == -1{
            return []
        }
        BlockListData.forEach { blockData in
            if blockData.blockCategoryIndex != currentCategoryIndex{
                blockData.blockPosition.forEach { position in
                    otherCategoryBlockIndexPathList.append((position[1]-1) * boardRowCount + (position[0] - 1))
                }
            }
        }
        return otherCategoryBlockIndexPathList
    }
}
