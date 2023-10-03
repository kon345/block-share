//
//  blockHelper.swift
//  blockShare
//
//  Created by 林裕和 on 2023/9/14.
//

import Foundation
import UIKit

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
    private let createBlockURL = "http://localhost:8888/blockShare/createBlock.php"
    
    static let shared = blockHelper()
    private init(){}
    
    var isNewBlockCreated = false
    var newBlockContent: String = ""
    var newBlockCategoryIndex: Int = -1
    var newBlockPosition = [[Int]]()
    
    
    
    
    func createBlock(blockContent:String, blockCategoryIndex:Int, blockPosition: [[Int]], groupID: Int, completion: @escaping DoneHandler<BlockID>){
        let parameters : [String : Any] = [blockContentKey: blockContent, blockCategoryIndexKey: blockCategoryIndex, blockPositionKey: blockPosition, groupIDKey: groupID]
        Communicator.shared.doPost(createBlockURL,parameters: parameters, completion: completion)
    }
    
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
}
