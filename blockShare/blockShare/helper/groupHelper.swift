//
//  groupHelper.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/15.
//

import Foundation

struct Group: Codable {
    var groupID:Int
    var groupName: String
    var creatorID: Int
    var category : [String]
    var memberCount: Int
    
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            groupID = try container.decode(Int.self, forKey: .groupID)
            groupName = try container.decode(String.self, forKey: .groupName)
            creatorID = try container.decode(Int.self, forKey: .creatorID)

            // 將 category 字符串解析為字符串數組
            let categoryString = try container.decode(String.self, forKey: .category)
            if let data = categoryString.data(using: .utf8),
               let categories = try? JSONDecoder().decode([String].self, from: data) {
                category = categories
            } else {
                category = []
            }

            memberCount = try container.decode(Int.self, forKey: .memberCount)
        }
}

class GroupHelper{
    private let userIDKey = "userID"
    private let groupNameKey = "groupName"
    private let groupCategoryKey = "groupCategory"
    private let creatorIDKey = "creatorID"
    private let createGroupURL = "http://localhost:8888/blockShare/createGroup.php"
    private let getGroupListURL = "http://localhost:8888/blockShare/getGroupList.php?userID="
    
    static let shared = GroupHelper()
    private init(){}
    
    var groupListData:[Group] = []
    var currentGroupIndex: Int = 0
    var currentGroupData: Group? {
        return groupListData.count > 0 ? groupListData[currentGroupIndex] : nil
    }
    
    func createGroup(name:String, category:[String], userID: Int, completion: @escaping DoneHandler<Group>){
        let parameters : [String : Any] = [groupNameKey: name, groupCategoryKey: category, creatorIDKey: userID]
        Communicator.shared.doPost(createGroupURL,parameters: parameters, completion: completion)
    }
    
    func getGroupList(userID:Int, completion: @escaping DoneHandler<[Group]>){
        let parameters: [String : Any] = [userIDKey: userID]
        Communicator.shared.doGet(getGroupListURL, parameters: parameters, completion: completion)
    }
}
