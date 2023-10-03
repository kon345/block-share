//
//  User.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/8.
//

import Foundation
import CommonCrypto
import RNCryptor
import KeychainAccess

struct UserID: Codable{
    var userID:Int
}

struct AccountDuplicate: Codable{
    var accountDuplicate: Bool
}

struct Token: Codable{
    var token: String
}

struct UserInfo: Codable{
    var userID: Int
    var token: String
}

class userHelper{
    var userID = 0
    var isLoggined = false
    private var masterKey: String{
        var result  = "GHI"
        result += "$%"
        result += String(3*4-1)
        result += String(2*9)
        result += "dbafe".reversed()
        var total = 0
        for _ in 0..<53 {
            total += 1
        }
        result += String(total)
        result += "#@er$d".reversed()
        result = result.replacingOccurrences(of: "GHI", with: "")
        return result
    }
    private let saltLength = 16
    private let userNameKey = "username"
    private let accountKey = "account"
    private let passwordKey = "password"
    private let tokenKey = "token"
    private let createUserURL = "http://localhost:8888/blockShare/createUser.php"
    private let getUserIDURL = "http://localhost:8888/blockShare/getUserID.php?account="
    private let checkAccountDuplicateURL = "http://localhost:8888/blockShare/checkAccountDuplicate.php?account="
    private let userLoginURL = "http://localhost:8888/blockShare/userLogin.php"
    private let tokenLoginURL = "http://localhost:8888/blockShare/tokenLogin.php"
    
    
    static let shared = userHelper()
    private init(){}
    
    // 註冊新使用者
    // @param account
    // @param password
    // @param completion
    func createUser(username: String, account:String, password:String, completion: @escaping DoneHandler<UserID> ){
        let parameters : [String : Any] = [userNameKey: username, accountKey: account, passwordKey: password]
        Communicator.shared.doPost(createUserURL,parameters: parameters, completion: completion)
    }
    
    // 檢查帳號是否重複
    // @param account
    // @param completion
    func checkAccountDuplicate(account: String, completion: @escaping DoneHandler<AccountDuplicate>) {
        let parameters : [String : Any] = [accountKey: account]
        Communicator.shared.doGet(checkAccountDuplicateURL, parameters: parameters, completion: completion)
    }
    
    // 用帳號查UserID
    // @param account
    // @param completion
    func getUserID(account:String, completion: @escaping DoneHandler<UserID>){
        let parameters: [String : Any] = [accountKey: account]
        Communicator.shared.doGet(getUserIDURL, parameters: parameters, completion: completion)
    }
    
    // 帳號密碼登入
    // @param account
    // @param password
    // @param completion
    func login(account: String, password: String, completion: @escaping DoneHandler<UserInfo>){
        let parameters : [String : Any] = [accountKey: account, passwordKey: password]
        Communicator.shared.doPost(userLoginURL, parameters: parameters, completion: completion)
    }
    
    // token登入
    // @param token
    // @param completion
    func tokenLogin(token: String, completion: @escaping DoneHandler<UserID>){
        let parameters : [String : Any] = [tokenKey: token]
        Communicator.shared.doPost(tokenLoginURL, parameters: parameters, completion: completion)
    }
    
    //MARK: 加密
    
    // 取得儲存的salt或生成新的
    private func getSalt() -> String{
        let keychain = Keychain(service: "general.service")
        if  let salt = try? keychain[string: "salt"]?.decryptBase64(key: masterKey){
            return salt
        }else {
            let generatedSalt = generateSalt()
            keychain[string: "salt"] = generatedSalt.encryptBase64(key: masterKey)
            return generatedSalt
        }
    }
    
    // 生成隨機salt
    private func generateSalt() -> String {
        let saltData = Data((0..<saltLength).map { _ in UInt8.random(in: 0...255) })
        return saltData.base64EncodedString()
    }
    
    // hash密碼
    func hashPassword(password: String) -> String?{
        if let passwordData = password.data(using: .utf8), let saltData = Data(base64Encoded: getSalt()) {
            // 儲存hashData
            var hashData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
            
            // hash password
            passwordData.withUnsafeBytes { passwordBytes in
                saltData.withUnsafeBytes { saltBytes in
                    hashData.withUnsafeMutableBytes { hashBytes in
                        let context = UnsafeMutablePointer<CC_SHA256_CTX>.allocate(capacity: 1)
                        defer { context.deallocate() }
                        CC_SHA256_Init(context)
                        CC_SHA256_Update(context, saltBytes.baseAddress, CC_LONG(saltData.count))
                        CC_SHA256_Update(context, passwordBytes.baseAddress, CC_LONG(passwordData.count))
                        CC_SHA256_Final(hashBytes.bindMemory(to: UInt8.self).baseAddress, context)
                    }
                }
            }
            
            // 将哈希数据转换为十六进制字符串
            let hashString = hashData.map { String(format: "%02hhx", $0) }.joined()
            return hashString
        }
        return nil
    }
    //MARK: Token
    
    // 儲存登入token
    func saveToken(token: String){
        let keychain = Keychain(service: "general.service")
        let token = token.encryptBase64(key: masterKey)
        keychain[string: "token"] = token
    }
    
    // 取得已儲存token
    func getToken() -> String?{
        let keychain = Keychain(service: "general.service")
        if let token = try? keychain[string: "token"]?.decryptBase64(key: masterKey){
            return token
        }
        return nil
    }
}
