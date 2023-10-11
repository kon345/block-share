//
//  AddBlockVC.swift
//  blockShare
//
//  Created by 林裕和 on 2023/9/13.
//

import UIKit
import iOSDropDown

class AddBlockVC: UIViewController {
    // 分類
    var category: [String] = []
    // 選中的分類
    var pickedCategoryIndex = -1
    // 內容網址
    var inputURL = ""
    // 上一層的父VC
    var groupContentVC: GroupContentVC?
    
    enum textMessage : String {
        case categoryNotPicked = "分類未選擇"
        case URLisEmpty = "網址為空"
        case URLNotValid = "網址錯誤"
    }
    
    @IBOutlet weak var categoryDropDown: DropDown!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryErrorLabel: UILabel!
    @IBOutlet weak var URLErrorLabel: UILabel!
    @IBOutlet weak var URLTextField: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        URLTextField.delegate = self
        
        // 刪掉「無篩選」分類
        category.removeFirst()
        // 設置下拉選單
        categoryDropDown.optionArray = category
        categoryDropDown.optionImageArray = categoryImage
        categoryDropDown.didSelect { selectedText, index, id in
            self.pickedCategoryIndex = index
            self.categoryImageView.image = UIImage(named: categoryImage[self.pickedCategoryIndex])
            self.categoryImageView.layer.borderColor = UIColor.black.cgColor
            self.categoryImageView.layer.borderWidth = 1
            self.categoryErrorLabel.isHidden = true
        }
        
        // 背景按鈕樣式處理
        commonHelper.shared.assignbackground(view: self.view, backgroundName: "boyPlayTetris")
        commonHelper.shared.setPurpleOrangeBtn(button: confirmBtn)
        categoryErrorLabel.isHidden = true
        URLErrorLabel.isHidden = true
    }
    
    @IBAction func confirmBtnPressed(_ sender: Any) {
        URLTextField.resignFirstResponder()
        let valid1 = categoryValidation()
        let valid2 = URLValidation()
        
        if(valid1 && valid2){
            // 存入blockHelper的新方塊資料
            blockHelper.shared.newBlockContent = inputURL
            blockHelper.shared.newBlockCategoryIndex = pickedCategoryIndex
            blockHelper.shared.isNewBlockCreated = true
            self.dismiss(animated: true) {
                guard let groupContentVC = self.groupContentVC else{
                    return
                }
                groupContentVC.newBlockCreated()
            }
        }
    }
    
    func categoryValidation() -> Bool{
        if checkCategory() == false{
            categoryErrorLabel.text = textMessage.categoryNotPicked.rawValue
            categoryErrorLabel.isHidden = false
            return false
        }
        return true
    }
    
    func checkCategory() -> Bool{
        return pickedCategoryIndex > -1
    }
    
    func URLValidation() -> Bool{
        if inputURL.isEmpty {
            URLErrorLabel.text = textMessage.URLisEmpty.rawValue
            URLErrorLabel.isHidden = false
            return false
        }
        
        if checkURL(URLString: inputURL) == false {
            URLErrorLabel.text = textMessage.URLNotValid.rawValue
            URLErrorLabel.isHidden = false
            return false
        }
        return true
    }
    
    func checkURL(URLString: String) -> Bool{
        let urlPattern = #"^(https?|ftp)://[^\s/$.?#].[^\s]*$"#
        let regex = try? NSRegularExpression(pattern: urlPattern, options: .caseInsensitive)
        
        if let matches = regex?.matches(in: URLString, options: [], range: NSRange(location: 0, length: URLString.utf16.count)), !matches.isEmpty {
            return true
        }
        
        return false
    }
    
    // MARK: - Navigation
    /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     }
     */
}

// MARK: textField delegate
extension AddBlockVC: UITextFieldDelegate {
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
        
        // 儲存輸入網址
        if textField == URLTextField{
            inputURL = text
            URLErrorLabel.isHidden = true
        }
        
        return true
    }
    
    // 觸發點擊時
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 結束編輯
        self.view.endEditing(true)
    }
}
