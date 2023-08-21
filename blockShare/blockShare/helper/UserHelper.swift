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

class UserHelper{
    var userID = 0
    let username = "林"
    let userNameKey = "username"
    let accountKey = "account"
    let passwordKey = "password"
    let createUserURL = "http://localhost:8888/blockShare/createUser.php"
    let getUserIDURL = "http://localhost:8888/blockShare/getUserID.php?account="
    
    static let shared = UserHelper()
    private init(){}
    
    func createUser(account:String, password:String, completion: @escaping (Bool) -> Void ){
        let parameters : [String : Any] = [userNameKey: username, accountKey: account, passwordKey: password]
        print(parameters)
        Communicator.shared.doPost(createUserURL,parameters: parameters, completion: completion)
    }
    
    func getUserID(account:String, completion: @escaping DoneHandler<UserID>){
        let targetURL = getUserIDURL + account
        Communicator.shared.doGet(targetURL, responseType: UserID.self, completion: completion)
    }
}
