//
//  User.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/8.
//

import Foundation

struct UserID: Codable{
    var userID:Int
}

class userHelper{
    var userID = 0
    let username = "林"
    private let userNameKey = "username"
    private let accountKey = "account"
    private let passwordKey = "password"
    private let createUserURL = "http://localhost:8888/blockShare/createUser.php"
    private let getUserIDURL = "http://localhost:8888/blockShare/getUserID.php?account="
    
    static let shared = userHelper()
    private init(){}
    
    func createUser(account:String, password:String, completion: @escaping DoneHandler<UserID> ){
        let parameters : [String : Any] = [userNameKey: username, accountKey: account, passwordKey: password]
        Communicator.shared.doPost(createUserURL,parameters: parameters, completion: completion)
    }
    
    func getUserID(account:String, completion: @escaping DoneHandler<UserID>){
        let parameters: [String : Any] = [accountKey: account]
        Communicator.shared.doGet(getUserIDURL, parameters: parameters, completion: completion)
    }
}
