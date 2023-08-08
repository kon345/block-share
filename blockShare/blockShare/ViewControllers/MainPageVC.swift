//
//  MainPageVC.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/8.
//

import UIKit

class MainPageVC: UIViewController {
    // 帳號密碼登入區塊
    @IBOutlet weak var loginGroupView: UIView!
    // 群組列表區塊
    @IBOutlet weak var groupSelectionView: UIView!
    // 帳號輸入框
    @IBOutlet weak var accountInputArea: UITextField!
    // 密碼輸入框
    @IBOutlet weak var passwordInputArea: UITextField!
    // 群組列表
    @IBOutlet weak var groupListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // 未登入隱藏群組列表
        groupSelectionView.isHidden = true
        
        // 設定輸入框delegate
        accountInputArea.delegate = self
        passwordInputArea.delegate = self
    }
    
    // 登入按鈕按下
    @IBAction func loginBtnPressed(_ sender: Any) {
    }
    
    // 輸入群組碼按鈕按下
    @IBAction func groupCodeBtnPressed(_ sender: Any) {
    }
    
    // 創建新群組按鈕按下
    @IBAction func createGroupBtnPressed(_ sender: Any) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// textField delegate
extension MainPageVC: UITextFieldDelegate{
    // 按enter時
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // 結束編輯時更新資料
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // 沒有文字不做事
        guard let text = textField.text else{
            return true
        }
        
        switch textField{
        case accountInputArea:
            print("account = \(text)")
        case passwordInputArea:
            print("password = \(text)")
        default:
            return true;
        }
        return true
    }
    
    // 觸發點擊時
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 結束編輯
        self.view.endEditing(true)
    }
}
