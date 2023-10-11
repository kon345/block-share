//
//  groupHelper.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/15.
//

import Foundation

struct GroupCode: Codable{
    var groupCode: String
}

struct Group: Codable {
    var groupID:Int
    var groupName: String
    var creatorID: Int
    var category : [String]
    var memberCount: Int
    var groupCode: String
    
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
        groupCode = try container.decode(String.self, forKey: .groupCode)
    }
}

class GroupHelper{
    private let userIDKey = "userID"
    private let groupNameKey = "groupName"
    private let groupCategoryKey = "groupCategory"
    private let creatorIDKey = "creatorID"
    private let groupCodeKey = "groupCode"
    private let createGroupURL = "http://localhost:8888/blockShare/createGroup.php"
    private let getGroupListURL = "http://localhost:8888/blockShare/getGroupList.php"
    private let joinGroupURL = "http://localhost:8888/blockShare/joinGroup.php"
    
    static let shared = GroupHelper()
    private init(){}
    
    // 群組列表資料
    var groupListData:[Group] = []
    // 當前選到的群組編號
    var currentGroupIndex: Int = 0
    // 當前選到的群組資料
    var currentGroupData: Group? {
        return groupListData.count > 0 ? groupListData[currentGroupIndex] : nil
    }
    
    // 創建群組
    // @param name
    // @param category
    // @param userID
    // @param completion
    func createGroup(name:String, category:[String], userID: Int, completion: @escaping DoneHandler<GroupCode>){
        let parameters : [String : Any] = [groupNameKey: name, groupCategoryKey: category, creatorIDKey: userID]
        Communicator.shared.doPost(createGroupURL,parameters: parameters, completion: completion)
    }
    
    // 取得群組列表
    // @param userID
    // @param completion
    func getGroupList(userID:Int, completion: @escaping DoneHandler<[Group]>){
        let parameters: [String : Any] = [userIDKey: userID]
        Communicator.shared.doGet(getGroupListURL, parameters: parameters, completion: completion)
    }
    
    // 群組碼加入群組
    // @param userID
    // @param groupCode
    // @param completion
    func joinGroup(userID:Int, groupCode:String, completion: @escaping DoneHandler<GroupCode>){
        let parameters: [String : Any] = [userIDKey: userID, groupCodeKey: groupCode]
        Communicator.shared.doPost(joinGroupURL, parameters: parameters, completion: completion)
    }
}
