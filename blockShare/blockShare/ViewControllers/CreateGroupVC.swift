//
//  CreateGroupVC.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/11.
//

import UIKit

class CreateGroupVC: UIViewController {
    
    // 文字資料
    enum textMessage : String {
        case fullCategoryTitle = "分類已滿"
        case fullCategoryＭessage = "已達分類數量上限"
        case enterCategoryTitle = "新增分類"
        case enterCategoryＭessage = "請輸入分類名稱"
        case add = "新增"
        case cancel = "取消"
        case delete = "刪除"
        case finish = "完成"
        case confirm = "確定"
        case groupNameCannotBeEmpty = "群組名稱不可為空"
        case createSuccess = "創立成功"
        case createFailed = "創立失敗"
    }
    
    
    // 群組分類
    var groupCategory = ["梗圖","影片","情報"]
    
    @IBOutlet weak var groupNameInputArea: UITextField!
    @IBOutlet weak var groupCategoryList: UITableView!
    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var successFailView: UIView!
    @IBOutlet weak var successFailLabel: UILabel!
    @IBOutlet weak var GroupCodeLabel: UILabel!
    @IBOutlet weak var copyCodeBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        editBtn.title = textMessage.delete.rawValue
        successFailView.isHidden = true
        copyCodeBtn.isHidden = true
        
        // 設定delegate & dataSource
        groupNameInputArea.delegate = self
        groupCategoryList.dataSource = self
        groupCategoryList.delegate = self
        
        // 背景按鈕樣式處理
        commonHelper.shared.assignbackground(view: self.view, backgroundName: "CreateGroupBackground")
        navigationController?.navigationBar.tintColor = UIColor.purple
        commonHelper.shared.setPurpleOrangeBtn(button: copyCodeBtn)
        commonHelper.shared.setPurpleOrangeBtn(button: confirmBtn)
        let backgroundImage = UIImage(named: "CategoryTableViewBackground")
            let backgroundImageView = UIImageView(image: backgroundImage)
            groupCategoryList.backgroundView = backgroundImageView
    }
    
    @IBAction func addBtnPressed(_ sender: Any) {
        // 分類數量上限限制
        if groupCategory.count >= categoryColor.count{
            commonHelper.shared.showToastGlobal(message: textMessage.fullCategoryＭessage.rawValue)
            return
        }
        // 新增分類alert
        let addCategoryAlert = UIAlertController(title: textMessage.enterCategoryTitle.rawValue, message: textMessage.enterCategoryＭessage.rawValue, preferredStyle: .alert)
        addCategoryAlert.addTextField()
        let confirm = UIAlertAction(title: textMessage.add.rawValue, style: .default) { action in
            guard let textField = addCategoryAlert.textFields?.first, let text = textField.text, text != "" else{
                return
            }
            self.groupCategory.append(text)
            self.groupCategoryList.reloadData()
        }
        let cancel = UIAlertAction(title: textMessage.cancel.rawValue, style: .cancel)
        addCategoryAlert.addAction(confirm)
        addCategoryAlert.addAction(cancel)
        self.present(addCategoryAlert, animated: true)
    }
    
    @IBAction func editBtnPressed(_ sender: Any) {
        groupCategoryList.setEditing(!groupCategoryList.isEditing, animated: true)
        // 切換按鈕文字
        if groupCategoryList.isEditing == true {
            editBtn.title = textMessage.finish.rawValue
        } else {
            editBtn.title = textMessage.delete.rawValue
        }
    }
    
    @IBAction func confirmCreateBtnPressed(_ sender: Any) {
        guard let text = groupNameInputArea.text, text != "" else{
            commonHelper.shared.showToastGlobal(message: textMessage.groupNameCannotBeEmpty.rawValue)
            return
        }
        
        GroupHelper.shared.createGroup(name: text, category: groupCategory, userID: userHelper.shared.userID) { result, error in
            if let error = error{
                print("Create group error: \(error)")
                return
            }
            
            // 自訂error處理
            if result?.response.success == false, let errorCode = result?.response.errorCode{
                DispatchQueue.main.async {
                    let alert = commonHelper.shared.createAlert(title: textMessage.createFailed.rawValue, message: handleResponseError(errorMessage: errorCode), buttonTitle: textMessage.confirm.rawValue)
                    self.present(alert, animated: true)
                }
                return
            }
            
            guard let groupCode = result?.content?.groupCode else{
                print("no groupCode received.")
                return
            }
            
            DispatchQueue.main.async {
                self.createBtn.isEnabled = false
                self.successFailView.isHidden = false
                self.copyCodeBtn.isHidden = false
                self.successFailLabel.text = textMessage.createSuccess.rawValue
                self.GroupCodeLabel.text = groupCode
            }
        }
    }
    
    @IBAction func copyCodeBtnPressed(_ sender: Any) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = GroupCodeLabel.text
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

// MARK: textField delegate
extension CreateGroupVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

//MARK: groupCategoryList DataSource, Delegate
extension CreateGroupVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryCell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        var config = categoryCell.defaultContentConfiguration()
        // 顯示分類文字
        config.text = groupCategory[indexPath.row]
        // 畫顏色方塊
        let colorBlock = createBlockWithColor(color: categoryColor[indexPath.row], size: categoryBlockSize)
        config.image = colorBlock
        categoryCell.contentConfiguration = config
        return categoryCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            groupCategory.remove(at: indexPath.row)
            groupCategoryList.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // 畫分類方塊
    // @param color
    // @param size
    func createBlockWithColor(color: UIColor, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

