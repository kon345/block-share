//
//  String+RNCryptor.swift
//  HelloMySecurity
//
//  Created by 林裕和 on 2023/8/30.
//

import Foundation
import RNCryptor

extension String{
    func decryptBase64(key: String) throws -> String?{
        guard let encryptedData = Data(base64Encoded: self) else {
            print("Fail to convert from base64.")
            return nil
        }
        let originalData = try RNCryptor.decrypt(data: encryptedData, withPassword: key)
        return String(data: originalData, encoding: .utf8)
    }
    
    func encryptBase64(key:String) -> String?{
        //Self (a string) will be encrypt a a new base 64 string
        guard let data = self.data(using:.utf8) else {
            assertionFailure("Fail to convert to utf8 data")
            return nil
        }
        let encryptedData = RNCryptor.encrypt(data: data, withPassword: key)
        return encryptedData.base64EncodedString()
    }
}

