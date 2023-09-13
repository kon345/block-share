//
//  CreateGroupVC.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/11.
//

import UIKit

class CreateGroupVC: UIViewController {
    // 分類方塊大小
    let categoryBlockSize = CGSize(width: 30, height: 30)
    
    // 文字資料
    enum textMessage : String {
        case fullCategoryTitle = "分類已滿"
        case fullCategoryＭessage = "已達分類上限"
        case enterCategoryTitle = "新增分類"
        case enterCategoryＭessage = "請輸入分類名稱"
        case add = "新增"
        case cancel = "取消"
    }
    
    
    // 群組分類
    var groupCategory = ["梗圖","影片","情報"]
    

    @IBOutlet weak var groupNameInputArea: UITextField!
    @IBOutlet weak var groupCategoryList: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // 設定delegate & dataSource
        groupNameInputArea.delegate = self
        groupCategoryList.dataSource = self
        groupCategoryList.delegate = self
    }
    
    @IBAction func addBtnPressed(_ sender: Any) {
        // 分類數量上限限制
        if groupCategory.count >= categoryColor.count{
            let fullCategoryAlert = UIAlertController(title: textMessage.fullCategoryTitle.rawValue, message: textMessage.fullCategoryＭessage.rawValue, preferredStyle: .alert)
            let cancel = UIAlertAction(title: textMessage.cancel.rawValue, style: .cancel)
            fullCategoryAlert.addAction(cancel)
            self.present(fullCategoryAlert, animated: true)
            return
        }
        // 新增分類alert
        let addCategoryAlert = UIAlertController(title: textMessage.enterCategoryTitle.rawValue, message: textMessage.enterCategoryＭessage.rawValue, preferredStyle: .alert)
        // TODO: autoLayout報錯
        addCategoryAlert.addTextField()
        let confirm = UIAlertAction(title: textMessage.add.rawValue, style: .default) { action in
            guard let textField = addCategoryAlert.textFields?.first, let text = textField.text else{
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
    }
    
    @IBAction func confirmCreateBtnPressed(_ sender: Any) {
        guard let text = groupNameInputArea.text else{
            return
        }
        GroupHelper.shared.createGroup(name: text, category: groupCategory, userID: UserHelper.shared.userID) { result in
            if(result == false){
                print("create group failed!")
                return
            }
            DispatchQueue.main.async{
                self.navigationController?.popViewController(animated: true)
            }
        }
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

extension CreateGroupVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

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
    
    func createBlockWithColor(color: UIColor, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

