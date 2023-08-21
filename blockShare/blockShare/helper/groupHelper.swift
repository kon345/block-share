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
    var category : String
    var memberCount: Int
}

class GroupHelper{
    let groupNameKey = "groupName"
    let groupCategoryKey = "groupCategory"
    let creatorIDKey = "creatorID"
    let createGroupURL = "http://localhost:8888/blockShare/createGroup.php"
    let getGroupListURL = "http://localhost:8888/blockShare/getGroupList.php?userID="
    
    static let shared = GroupHelper()
    private init(){}
    
    func createGroup(name:String, category:[String], userID: Int, completion: @escaping (Bool) -> Void ){
        let parameters : [String : Any] = [groupNameKey: name, groupCategoryKey: category, creatorIDKey: userID]
        Communicator.shared.doPost(createGroupURL,parameters: parameters, completion: completion)
    }
    
    func getGroupList(userID:Int, completion: @escaping DoneHandler<[Group]>){
        let targetURL = getGroupListURL + "\(userID)"
        Communicator.shared.doGet(targetURL, responseType: [Group].self, completion: completion)
    }
}
