//
//  MainPageVC.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/8.
//

import UIKit

class MainPageVC: UIViewController {
    // 登入/註冊 頁籤
    var currentPageTag = pageTag.register
    // 帳號重複檢查結果
    var isAccountDuplicated = false
    
    enum textMessage : String {
        case deleteAccountWarning = "刪除帳號警告"
        case confirmDeleteAccount = "確定刪除帳號嗎？\n請輸入密碼來確認刪除"
        case accountCanOnlyContainAlpNum = "帳號只能包含英數字"
        case passwordValidWarning = "密碼必須為包含大小寫8碼以上英數字符號"
        case accountPlaceholder = "限定英數字"
        case passwordPlaceholder = "包含大小寫8碼以上英數字符號"
        case usernameCannotbeEmpty = "暱稱不可為空"
        case accountCannotbeEmpty = "帳號不可為空"
        case passwordCannotbeEmpty = "密碼不可為空"
        case accountIsDuplicated = "帳號重複"
        case enterCodeTitle = "群組碼"
        case enterCodeMessage = "請輸入群組碼"
        case confirm = "確定"
        case send = "送出"
        case cancel = "取消"
        case members = "名成員"
        case getGroupListFailed = "無法取得群組列表"
        case deleteAccountFailed = "刪除帳號失敗"
        case joinGroupSuccess = "加入群組成功"
        case joinGroupFailed = "加入群組失敗"
        case registerFailed = "註冊失敗"
        case registerSuccessPleaseLogin = "註冊成功，請輸入帳號密碼登入。"
        case loginFailed = "登入失敗"
    }
    
    // constraint調整常數
    enum moveConstants : CGFloat {
        case groupSelectionNewTop = 100
        case groupSelectionNewBottom = 200
        case groupSelectionOriginalBottom = 10
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
    // 刪除帳號按鈕
    @IBOutlet weak var deleteAccountBtn: UIButton!
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
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var groupCodeBtn: UIButton!
    @IBOutlet weak var createGroupBtn: UIButton!
    @IBOutlet weak var groupListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // 隱藏backButton(不讓回到上一層PreloadVC)
        navigationItem.hidesBackButton = true
        
        // 隱藏警告文字
        usernameWarningLabel.isHidden = true
        accountWarningLabel.isHidden = true
        passwordWarningLabel.isHidden = true
        
        // 設定輸入框delegate
        usernameInputArea.delegate = self
        accountInputArea.delegate = self
        passwordInputArea.delegate = self
        
        // 設定群組列表delegate
        groupListTableView.dataSource = self
        groupListTableView.delegate = self
        
        // UI依照登入狀況改變
        if userHelper.shared.isLoggined{
            afterLoginUIChange()
        } else {
            beforeLoginUIChange()
        }
        
        // 背景按鈕樣式處理
        commonHelper.shared.assignbackground(view: self.view, backgroundName: "MainPageBackground")
        navigationController?.navigationBar.tintColor = UIColor.purple
        commonHelper.shared.setPurpleOrangeBtn(button: registerBtn)
        commonHelper.shared.setPurpleOrangeBtn(button: loginBtn)
        commonHelper.shared.setPurpleOrangeBtn(button: sendBtn)
        commonHelper.shared.setPurpleOrangeBtn(button: createGroupBtn)
        commonHelper.shared.setPurpleOrangeBtn(button: groupCodeBtn)
        let backgroundImage = UIImage(named: "GroupListTableViewBackground")
        let backgroundImageView = UIImageView(image: backgroundImage)
        groupListTableView.backgroundView = backgroundImageView
        
        // 設定初始選取按鈕
        registerBtn.layer.borderWidth = 2
        registerBtn.layer.borderColor = UIColor.black.cgColor
        accountInputArea.placeholder = textMessage.accountPlaceholder.rawValue
        passwordInputArea.placeholder = textMessage.passwordPlaceholder.rawValue
        // 回復方角
        registerBtn.layer.cornerRadius = 0
        loginBtn.layer.cornerRadius = 0
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
                
                // 自訂error處理
                if result?.response.success == false, let errorCode = result?.response.errorCode{
                    DispatchQueue.main.async {
                        let alert = commonHelper.shared.createAlert(title: textMessage.getGroupListFailed.rawValue, message: handleResponseError(errorMessage: errorCode), buttonTitle: textMessage.confirm.rawValue)
                        self.present(alert, animated: true)
                    }
                    return
                }
                
                // 取得群組列表資料
                guard let groupList = result?.content else{
                    print("No group list")
                    return
                }
                
                // 儲存群組列表資料
                GroupHelper.shared.groupListData = groupList
                DispatchQueue.main.async {
                    // 刷新列表
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
        // 切換頁籤、UI
        currentPageTag = pageTag.register
        // 顯示暱稱欄位
        usernameLabel.isHidden = false
        usernameInputArea.isHidden = false
        usernameInputArea.isHidden = false
        accountInputArea.placeholder = textMessage.accountPlaceholder.rawValue
        passwordInputArea.placeholder = textMessage.passwordPlaceholder.rawValue
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
        // 切換頁籤、UI
        currentPageTag = pageTag.login
        // 隱藏暱稱欄位
        usernameLabel.isHidden = true
        usernameInputArea.isHidden = true
        usernameInputArea.isHidden = true
        accountInputArea.placeholder = ""
        passwordInputArea.placeholder = ""
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
    
    // 刪除帳號按鈕按下
    @IBAction func deleteAccountBtnPressed(_ sender: Any) {
        let deleteAccountConfirmAlert = UIAlertController(title: textMessage.deleteAccountWarning.rawValue, message: textMessage.confirmDeleteAccount.rawValue, preferredStyle: .alert)
        deleteAccountConfirmAlert.addTextField { textField in
            textField.isSecureTextEntry = true
        }
        let confirm = UIAlertAction(title: textMessage.confirm.rawValue, style: .default) { action in
            guard let password = deleteAccountConfirmAlert.textFields?.first?.text,
                  let token = userHelper.shared.getToken(),
                  let hashedContent = userHelper.shared.hashPassword(password: password) else {
                return
            }
            
            userHelper.shared.deleteUser(token:token , userID: userHelper.shared.userID , password: hashedContent) { result, error in
                if let error = error {
                    print("Delete User error: \(error)")
                    return
                }
                
                // 自訂error處理
                if result?.response.success == false, let errorCode = result?.response.errorCode{
                    DispatchQueue.main.async {
                        let alert = commonHelper.shared.createAlert(title: textMessage.deleteAccountFailed.rawValue, message: handleResponseError(errorMessage: errorCode), buttonTitle: textMessage.confirm.rawValue)
                        self.present(alert, animated: true)
                    }
                    return
                }
                
                // 刪除keyChain的Token
                userHelper.shared.clearToken()
                DispatchQueue.main.async {
                    self.beforeLoginUIChange()
                }
                
            }
        }
        let cancel = UIAlertAction(title: textMessage.cancel.rawValue, style: .cancel)
        deleteAccountConfirmAlert.addAction(confirm)
        deleteAccountConfirmAlert.addAction(cancel)
        self.present(deleteAccountConfirmAlert, animated: true)
    }
    
    // 輸入群組碼按鈕按下
    @IBAction func groupCodeBtnPressed(_ sender: Any) {
        let enterCodeAlert = UIAlertController(title: textMessage.enterCodeTitle.rawValue, message: textMessage.enterCodeMessage.rawValue, preferredStyle: .alert)
        enterCodeAlert.addTextField()
        let send = UIAlertAction(title: textMessage.send.rawValue, style: .default) { action in
            guard let groupCode = enterCodeAlert.textFields?.first?.text else{
                return
            }
            GroupHelper.shared.joinGroup(userID: userHelper.shared.userID, groupCode: groupCode) { result, error in
                if let error = error{
                    print("join group failed: \(error)")
                    return
                }
                
                // 自訂error處理
                if result?.response.success == false, let errorCode = result?.response.errorCode{
                    DispatchQueue.main.async {
                        let alert = commonHelper.shared.createAlert(title: textMessage.joinGroupFailed.rawValue, message: handleResponseError(errorMessage: errorCode), buttonTitle: textMessage.confirm.rawValue)
                        self.present(alert, animated: true)
                    }
                    return
                }
                // 重新抓取群組列表
                self.viewDidAppear(false)
                DispatchQueue.main.async {
                    commonHelper.shared.showToastGlobal(message: textMessage.joinGroupSuccess.rawValue)
                }
            }
        }
        let cancel = UIAlertAction(title: textMessage.cancel.rawValue, style: .cancel)
        enterCodeAlert.addAction(send)
        enterCodeAlert.addAction(cancel)
        self.present(enterCodeAlert, animated: true)
    }
    
    // 檢查所有輸入資料是否合規定(註冊）
    func validateAllInput() -> Bool{
        var isValid = true
        // 沒有輸入暱稱警告＆返回
        if(textFieldEmptyWarning(textfield: usernameInputArea, warningLabel: usernameWarningLabel, warningText: textMessage.usernameCannotbeEmpty.rawValue)){
            isValid = false
        }
        // 沒有輸入帳號警告＆返回
        if textFieldEmptyWarning(textfield: accountInputArea, warningLabel: accountWarningLabel, warningText: textMessage.accountCannotbeEmpty.rawValue){
            isValid = false
        }
        // 沒有輸入密碼警告＆返回
        if textFieldEmptyWarning(textfield: passwordInputArea, warningLabel: passwordWarningLabel, warningText: textMessage.passwordCannotbeEmpty.rawValue) {
            isValid = false
        }
        
        if accountInvalidWarning(textField: accountInputArea, warningText: textMessage.accountCanOnlyContainAlpNum.rawValue){
            isValid = false
        }
        
        if passwordInvalidWarning(textField: passwordInputArea, warningText: textMessage.passwordValidWarning.rawValue){
            isValid = false
        }
        return isValid
    }
    
    // 檢查輸入框不為空否則跳警告回傳false
    // @param textField
    // @param warningLabel
    // @param warningText
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
        // 輸入資料驗證失敗不做事
        if validateAllInput() == false {
            return
        }
        
        if let username = usernameInputArea.text, let account = accountInputArea.text, let password = passwordInputArea.text{
            guard let hashResult = userHelper.shared.hashPassword(password: password) else{
                return
            }
            // 帳號不重複才註冊
            if isAccountDuplicated == false{
                userHelper.shared.createUser(username: username, account: account, password: hashResult){ result, error in
                    if let error = error{
                        print("Create User Failed: \(error)")
                        return
                    }
                    
                    // 自訂error處理
                    if result?.response.success == false, let errorCode = result?.response.errorCode{
                        DispatchQueue.main.async {
                            let alert = commonHelper.shared.createAlert(title: textMessage.registerFailed.rawValue, message: handleResponseError(errorMessage: errorCode), buttonTitle: textMessage.confirm.rawValue)
                            self.present(alert, animated: true)
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        // 切換到登入頁籤
                        self.loginBtnPressed(self.loginBtn!)
                        commonHelper.shared.showToastGlobal(message: textMessage.registerSuccessPleaseLogin.rawValue)
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
                return
            }
            userHelper.shared.login(account: account, password: hashResult) { result, error in
                if let error = error{
                    print("login error:\(error)")
                    return
                }
                
                // 自訂error處理
                if result?.response.success == false, let errorCode = result?.response.errorCode{
                    DispatchQueue.main.async {
                        let alert = commonHelper.shared.createAlert(title: textMessage.loginFailed.rawValue, message: handleResponseError(errorMessage: errorCode), buttonTitle: textMessage.confirm.rawValue)
                        self.present(alert, animated: true)
                    }
                    return
                }
                
                // 儲存token
                guard let token = result?.content?.token else{
                    print("no token received!")
                    return
                }
                userHelper.shared.saveToken(token: token)
                
                // 儲存userID
                guard let userID = result?.content?.userID else{
                    print("no userID received!")
                    return
                }
                userHelper.shared.userID = userID
                userHelper.shared.isLoggined = true
                DispatchQueue.main.async {
                    self.clearAlltextField()
                    self.afterLoginUIChange()
                }
            }
        }
    }
    
    // 登入後UI轉換
    func afterLoginUIChange(){
        // 隱藏登入顯示群組列表
        loginGroupView.isHidden = true
        groupSelectionView.isHidden = false
        // 群組列表上移
        if groupSelectionTopConstraint != nil{
            groupSelectionTopConstraint.isActive = false
        }
        groupSelectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: moveConstants.groupSelectionNewTop.rawValue).isActive = true
        groupSelectionBtmConstraint.constant = moveConstants.groupSelectionNewBottom.rawValue
        deleteAccountBtn.isHidden = false
        deleteAccountBtn.isEnabled = true
    }
    
    // 登入前UI轉換
    func beforeLoginUIChange(){
        // 隱藏登入顯示群組列表
        loginGroupView.isHidden = false
        groupSelectionView.isHidden = true
        // 群組列表上移
        groupSelectionBtmConstraint.constant = moveConstants.groupSelectionOriginalBottom.rawValue
        deleteAccountBtn.isHidden = true
        deleteAccountBtn.isEnabled = false
    }
    
    func isAccountValid(input: String) -> Bool {
        let alphanumericRegex = "^[a-zA-Z0-9]+$"
        let alphanumericTest = NSPredicate(format: "SELF MATCHES %@", alphanumericRegex)
        return alphanumericTest.evaluate(with: input)
    }
    
    func accountInvalidWarning(textField:UITextField, warningText: String) -> Bool{
        guard let input = textField.text else {
            return true
        }
        if isAccountValid(input: input){
            accountWarningLabel.isHidden = true
            accountWarningLabel.text = ""
            return false
        } else {
            accountWarningLabel.isHidden = false
            accountWarningLabel.text = warningText
            return true
        }
    }
    
    func isValidPassword(input: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d$@$#!%*?&]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: input)
    }
    
    func passwordInvalidWarning(textField:UITextField, warningText: String) -> Bool{
        guard let input = textField.text else {
            return true
        }
        if isValidPassword(input: input){
            passwordWarningLabel.isHidden = true
            passwordWarningLabel.text = ""
            return false
        } else {
            passwordWarningLabel.isHidden = false
            passwordWarningLabel.text = warningText
            return true
        }
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goToGroup", let groupContentVC = segue.destination as? GroupContentVC, let indexPath = groupListTableView.indexPathForSelectedRow{
            groupContentVC.currentGroupID = GroupHelper.shared.groupListData[indexPath.row].groupID
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
            
            // 帳號不合法警告(註冊)
            if currentPageTag == .register{
                if accountInvalidWarning(textField: textField, warningText: textMessage.accountCanOnlyContainAlpNum.rawValue){
                    return true
                }
            }
            
            // 完成帳號輸入時呼叫api檢查帳號是否重複
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
            // 沒有輸入密碼警告
            if textFieldEmptyWarning(textfield: textField, warningLabel: passwordWarningLabel, warningText: textMessage.passwordCannotbeEmpty.rawValue) {
                return true
            }
            
            // 密碼不合法警告(註冊)
            if currentPageTag == .register{
                if passwordInvalidWarning(textField: textField, warningText: textMessage.passwordValidWarning.rawValue){
                    return true
                }
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
