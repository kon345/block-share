//
//  MainPageVC.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/8.
//

import UIKit

class MainPageVC: UIViewController {
    var data = ["1","3","4"]
    var groupData : [Group] = []
    
    enum textMessage : String {
        case enterCodeTitle = "群組碼"
        case enterCodeMessage = "請輸入群組碼"
        case send = "送出"
        case cancel = "取消"
    }
    
    enum moveConstants : CGFloat {
        case groupSelectionNewTop = 100
        case groupSelectionNewBottom = 200
    }
    
    
    // 帳號密碼登入區塊
    @IBOutlet weak var loginGroupView: UIView!
    // 群組列表區塊
    @IBOutlet weak var groupSelectionView: UIView!
    @IBOutlet weak var groupSelectionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var groupSelectionBtmConstraint: NSLayoutConstraint!
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
        
        // 設定群組列表delegate
        groupListTableView.dataSource = self
        groupListTableView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if  UserHelper.shared.userID != 0{
            GroupHelper.shared.getGroupList(userID: UserHelper.shared.userID) { data in
                self.groupData = data
                print(self.groupData)
                DispatchQueue.main.async {
                    self.groupListTableView.reloadData()
                }
            }
        }
    }
    
    // 登入按鈕按下
    @IBAction func loginBtnPressed(_ sender: Any) {
        // 隱藏登入顯示群組列表
        loginGroupView.isHidden = true
        groupSelectionView.isHidden = false
        // 群組列表上移
        groupSelectionTopConstraint.isActive = false
        groupSelectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: moveConstants.groupSelectionNewTop.rawValue).isActive = true
        groupSelectionBtmConstraint.constant = 200
        if let account = accountInputArea.text, account != "", let password = passwordInputArea.text, password != ""{
            UserHelper.shared.createUser(account: account, password: password) { result in
                if(result == false){
                    print("create user failed!")
                }
                Task{
                    // 取得userID
                    UserHelper.shared.getUserID(account: account) { userID in
                        UserHelper.shared.userID = userID.userID
                    }
                }
            }
        }
    }
    
    // 輸入群組碼按鈕按下
    @IBAction func groupCodeBtnPressed(_ sender: Any) {
        let enterCodeAlert = UIAlertController(title: textMessage.enterCodeTitle.rawValue, message: textMessage.enterCodeMessage.rawValue, preferredStyle: .alert)
        // TODO: autoLayout報錯
        enterCodeAlert.addTextField()
        let confirm = UIAlertAction(title: textMessage.send.rawValue, style: .default) { action in
           // TODO: 送出加入群組request
        }
        let cancel = UIAlertAction(title: textMessage.cancel.rawValue, style: .cancel)
        enterCodeAlert.addAction(confirm)
        enterCodeAlert.addAction(cancel)
        self.present(enterCodeAlert, animated: true)
    }
    
    // 創建新群組按鈕按下
    @IBAction func createGroupBtnPressed(_ sender: Any) {
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

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

extension MainPageVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groupCell = groupListTableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        var config = groupCell.defaultContentConfiguration()
        config.text = groupData[indexPath.row].groupName
        groupCell.contentConfiguration = config
        return groupCell
    }
 
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }

}
