//
//  HandleResponseError.swift
//  blockShare
//
//  Created by 林裕和 on 2023/10/6.
//

import Foundation

func handleResponseError(errorMessage: String) -> String{
    switch errorMessage{
    // MARK: tokenLogin
    case "Token Invalid, Failed to get userID":
        return "登入憑證紀錄異常，請重新安裝APP!"
    case "Token not provided.":
        return "登入憑證傳送失敗。"
    // MARK: getGroupList
    case "UserID not provided.":
        return "使用者ID傳送失敗。"
    // MARK: deleteAccount
    case "Password Incorrect.":
        return "密碼錯誤。"
    case "Token invalid for account.":
        return "憑證異常。"
    case "Password not provided.":
        return "密碼傳送失敗。"
    // MARK: joinGroup
    case "Invalid Group Code.":
        return "未找到對應的群組，請確認後重新輸入。"
    case "GroupCode not provided.":
        return "群組碼傳送失敗。"
    // MARK: createUser
    case "Username not provided.":
        return "暱稱傳送失敗。"
    case "Account not provided.":
        return "帳號傳送失敗。"
    // MARK: login
    case "Account or Password Incorrect.":
        return "帳號或密碼錯誤，請確認後重新登入。"
    // MARK: createGroup
    case "GroupName not provided.":
        return "群組名稱傳送失敗。"
    case "GroupCategory not provided.":
        return "群組分類傳送失敗。"
    case "CreatorID not provided.":
        return "創建者ID傳送失敗。"
    // MARK: createBlock
    case "BlockContent not provided.":
        return "方塊網址傳送失敗。"
    case "BlockCategoryIndex not provided.":
        return "方塊分類傳送失敗。"
    case "BlockPosition not provided.":
        return "方塊位置傳送失敗。"
    case "GroupID not provided.":
        return "群組編號傳送失敗。"
    // MARK: getBlockList
    case "BlockID not provided.":
        return "起始方塊編號傳送錯誤"
    case let error where error.hasPrefix("Database error:"):
        return "資料庫錯誤。"
    default:
        return "API錯誤。"
    }
}
