//
//  MainPageVC.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/8.
//

import UIKit

class MainPageVC: UIViewController {
    var currentPageTag = pageTag.register
    var isAccountDuplicated = false
    
    enum textMessage : String {
        case usernameCannotbeEmpty = "暱稱不可為空"
        case accountCannotbeEmpty = "帳號不可為空"
        case passwordCannotbeEmpty = "密碼不可為空"
        case accountIsDuplicated = "帳號重複"
        case enterCodeTitle = "群組碼"
        case enterCodeMessage = "請輸入群組碼"
        case send = "送出"
        case cancel = "取消"
        case members = "名成員"
    }
    
    enum moveConstants : CGFloat {
        case groupSelectionNewTop = 100
        case groupSelectionNewBottom = 200
    }
    
    enum pageTag{
        case register
        case login
    }
    
    
    
    // 帳號密碼登入區塊
    @IBOutlet weak var loginGroupView: UIView!
    // 群組列表區塊
    @IBOutlet weak var groupSelectionView: UIView!
    @IBOutlet weak var groupSelectionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var groupSelectionBtmConstraint: NSLayoutConstraint!
    // 註冊按鈕
    @IBOutlet weak var registerBtn: UIButton!
    // 登入按鈕
    @IBOutlet weak var loginBtn: UIButton!
    // 暱稱輸入框
    @IBOutlet weak var usernameInputArea: UITextField!
    // 帳號輸入框
    @IBOutlet weak var accountInputArea: UITextField!
    // 密碼輸入框
    @IBOutlet weak var passwordInputArea: UITextField!
    // 暱稱標籤文字
    @IBOutlet weak var usernameLabel: UILabel!
    // 暱稱警告文字
    @IBOutlet weak var usernameWarningLabel: UILabel!
    // 帳號警告文字
    @IBOutlet weak var accountWarningLabel: UILabel!
    // 密碼警告文字
    @IBOutlet weak var passwordWarningLabel: UILabel!
    // 群組列表
    @IBOutlet weak var groupListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        // 未登入隱藏群組列表
        groupSelectionView.isHidden = true
        
        // 隱藏警告文字
        usernameWarningLabel.isHidden = true
        accountWarningLabel.isHidden = true
        passwordWarningLabel.isHidden = true
        
        // 設定初始選取按鈕
        registerBtn.layer.borderWidth = 2
        registerBtn.layer.borderColor = UIColor.black.cgColor
        
        // 設定輸入框delegate
        usernameInputArea.delegate = self
        accountInputArea.delegate = self
        passwordInputArea.delegate = self
        
        // 設定群組列表delegate
        groupListTableView.dataSource = self
        groupListTableView.delegate = self
        
        if userHelper.shared.isLoggined{
            // 隱藏登入顯示群組列表
            loginGroupView.isHidden = true
            groupSelectionView.isHidden = false
            // 群組列表上移
            groupSelectionTopConstraint.isActive = false
            groupSelectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: moveConstants.groupSelectionNewTop.rawValue).isActive = true
            groupSelectionBtmConstraint.constant = 200
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 有登入（有userID)呼叫api取得加入的群組列表
        if  userHelper.shared.userID != 0{
            GroupHelper.shared.getGroupList(userID: userHelper.shared.userID) { result, error in
                if let error = error{
                    print("Get group list Failed: \(error)")
                    return
                }
                guard let groupList = result?.content else{
                    assertionFailure("No group list")
                    return
                }
                GroupHelper.shared.groupListData = groupList
                DispatchQueue.main.async {
                    self.groupListTableView.reloadData()
                }
            }
        }
    }
    
    // 註冊按鈕按下
    @IBAction func registerBtnPressed(_ sender: Any) {
        if currentPageTag == pageTag.register{
            return
        }
        clearAlltextField()
        currentPageTag = pageTag.register
        usernameLabel.isHidden = false
        usernameInputArea.isHidden = false
        usernameInputArea.isHidden = false
        registerBtn.layer.borderWidth = 2
        registerBtn.layer.borderColor = UIColor.black.cgColor
        loginBtn.layer.borderWidth = 0
    }
    
    // 登入按鈕按下
    @IBAction func loginBtnPressed(_ sender: Any) {
        if currentPageTag == pageTag.login{
            return
        }
        clearAlltextField()
        currentPageTag = pageTag.login
        usernameLabel.isHidden = true
        usernameInputArea.isHidden = true
        usernameInputArea.isHidden = true
        loginBtn.layer.borderWidth = 2
        loginBtn.layer.borderColor = UIColor.black.cgColor
        registerBtn.layer.borderWidth = 0
    }
    
    // 送出按鈕按下
    @IBAction func sendBtnPressed(_ sender: Any) {
        switch currentPageTag{
        case .register:
            handleRegisterAPI()
        case .login:
            handleLoginAPI()
        }
    }
    
    // 輸入群組碼按鈕按下
    @IBAction func groupCodeBtnPressed(_ sender: Any) {
        let enterCodeAlert = UIAlertController(title: textMessage.enterCodeTitle.rawValue, message: textMessage.enterCodeMessage.rawValue, preferredStyle: .alert)
        // TODO: autoLayout報錯
        enterCodeAlert.addTextField()
        let confirm = UIAlertAction(title: textMessage.send.rawValue, style: .default) { action in
            // TODO: 送出加入群組request
            guard let groupCode = enterCodeAlert.textFields?.first?.text else{
                print("no groupCode input")
                return
            }
            GroupHelper.shared.joinGroup(userID: userHelper.shared.userID, groupCode: groupCode) { result, error in
                if let error = error{
                    print("join group failed: \(error)")
                    return
                }
                self.viewDidAppear(false)
            }
        }
        let cancel = UIAlertAction(title: textMessage.cancel.rawValue, style: .cancel)
        enterCodeAlert.addAction(confirm)
        enterCodeAlert.addAction(cancel)
        self.present(enterCodeAlert, animated: true)
    }
    
    // 創建新群組按鈕按下
    @IBAction func createGroupBtnPressed(_ sender: Any) {
    }
    
    // 檢查所有輸入資料是否為空
    func validateAllInput() -> Bool{
        // 沒有輸入暱稱警告＆返回
        if(textFieldEmptyWarning(textfield: usernameInputArea, warningLabel: usernameWarningLabel, warningText: textMessage.usernameCannotbeEmpty.rawValue)){
            return false
        }
        // 沒有輸入帳號警告＆返回
        if textFieldEmptyWarning(textfield: accountInputArea, warningLabel: accountWarningLabel, warningText: textMessage.accountCannotbeEmpty.rawValue){
            return false
        }
        // 沒有輸入密碼警告＆返回
        if textFieldEmptyWarning(textfield: passwordInputArea, warningLabel: passwordWarningLabel, warningText: textMessage.passwordCannotbeEmpty.rawValue) {
            return false
        }
        return true
    }
    
    // 檢查輸入框
    func textFieldEmptyWarning(textfield: UITextField, warningLabel: UILabel, warningText:String) -> Bool{
        guard let input = textfield.text, input != "" else {
            warningLabel.isHidden = false
            warningLabel.text = warningText
            return true
        }
        warningLabel.isHidden = true
        return false
    }
    
    // 清除所有輸入框內容
    func clearAlltextField(){
        usernameInputArea.text = ""
        accountInputArea.text = ""
        passwordInputArea.text = ""
    }
    
    // 送出註冊API
    func handleRegisterAPI(){
        if validateAllInput() == false {
            return
        }
        
        if let username = usernameInputArea.text, let account = accountInputArea.text, let password = passwordInputArea.text{
            guard let hashResult = userHelper.shared.hashPassword(password: password) else{
                assertionFailure("hash password Failed")
                return
            }
            // 帳號不重複
            if isAccountDuplicated == false{
                userHelper.shared.createUser(username: username, account: account, password: hashResult){ result, error in
                    if let error = error{
                        print("Create User Failed: \(error)")
                        return
                    }
                    DispatchQueue.main.async {
                        self.loginBtnPressed(self.loginBtn!)
                    }
                }
            }
        }
    }
    
    // 送出登入API
    func handleLoginAPI(){
        if textFieldEmptyWarning(textfield: accountInputArea, warningLabel: accountWarningLabel, warningText: textMessage.accountCannotbeEmpty.rawValue){
            return
        }
        
        if textFieldEmptyWarning(textfield: passwordInputArea, warningLabel: passwordWarningLabel, warningText: textMessage.passwordCannotbeEmpty.rawValue){
            return
        }
        
        if let account = accountInputArea.text, let password = passwordInputArea.text{
            guard let hashResult = userHelper.shared.hashPassword(password: password) else{
                assertionFailure("hash password Failed")
                return
            }
            userHelper.shared.login(account: account, password: hashResult) { result, error in
                if let error = error{
                    print("login error:\(error)")
                    return
                }
                guard let token = result?.content?.token else{
                    print("no token received!")
                    return
                }
                userHelper.shared.saveToken(token: token)
                guard let userID = result?.content?.userID else{
                    print("no userID received!")
                    return
                }
                userHelper.shared.userID = userID
                userHelper.shared.isLoggined = true
                DispatchQueue.main.async {
                    // 隱藏登入顯示群組列表
                    self.loginGroupView.isHidden = true
                    self.groupSelectionView.isHidden = false
                    // 群組列表上移
                    self.groupSelectionTopConstraint.isActive = false
                    self.groupSelectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: moveConstants.groupSelectionNewTop.rawValue).isActive = true
                    self.groupSelectionBtmConstraint.constant = 200
                }
            }
        }
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goToGroup", let groupContentVC = segue.destination as? GroupContentVC, let indexPath = groupListTableView.indexPathForSelectedRow{
            groupContentVC.currentGroupID = GroupHelper.shared.groupListData[indexPath.row].groupID
            print(groupContentVC.currentGroupID)
        }
    }
    
}

//MARK: textField delegate
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
        case usernameInputArea:
            // 沒有輸入暱稱警告
            if(textFieldEmptyWarning(textfield: textField, warningLabel: usernameWarningLabel, warningText: textMessage.usernameCannotbeEmpty.rawValue)){
                return true
            }
        case accountInputArea:
            // 沒有輸入帳號警告
            if textFieldEmptyWarning(textfield: textField, warningLabel: accountWarningLabel, warningText: textMessage.accountCannotbeEmpty.rawValue){
                return true
            }
            // 註冊時呼叫api檢查帳號是否重複
            if currentPageTag == pageTag.register{
                userHelper.shared.checkAccountDuplicate(account: text) { result, error in
                    if let error = error{
                        print("Check account duplicate error: \(error)")
                        return
                    }
                    
                    if result?.content?.accountDuplicate == true{
                        self.isAccountDuplicated = true
                        // 顯示帳號重複警告
                        DispatchQueue.main.async {
                            self.accountWarningLabel.isHidden = false
                            self.accountWarningLabel.text = textMessage.accountIsDuplicated.rawValue
                        }
                    } else {
                        self.isAccountDuplicated = false
                        DispatchQueue.main.async {
                            self.accountWarningLabel.isHidden = true
                        }
                    }
                }
            }
        case passwordInputArea:
            if textFieldEmptyWarning(textfield: textField, warningLabel: passwordWarningLabel, warningText: textMessage.passwordCannotbeEmpty.rawValue) {
                return true
            }
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

//MARK: groupList DataSource, Delegate
extension MainPageVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GroupHelper.shared.groupListData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groupCell = groupListTableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        var config = groupCell.defaultContentConfiguration()
        config.text = GroupHelper.shared.groupListData[indexPath.row].groupName
        config.secondaryText = String(GroupHelper.shared.groupListData[indexPath.row].memberCount) + textMessage.members.rawValue
        groupCell.contentConfiguration = config
        return groupCell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        GroupHelper.shared.currentGroupIndex = indexPath.row
    }
}
