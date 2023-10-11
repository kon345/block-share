//
//  preloadVC.swift
//  blockShare
//
//  Created by 林裕和 on 2023/10/1.
//

import UIKit
import NVActivityIndicatorView
import Alamofire

class PreloadVC: UIViewController {
    enum textMessage: String{
        case connectionErrorTitle = "連線錯誤"
        case connectionErrorMessage = "無法連接到伺服器，請確認網路連線後重新啟動App"
        case confirm = "確定"
        case tokenLoginFailed = "憑證登入錯誤"
    }
    
    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.startAnimating()
        // 沒有Token
        guard let token = userHelper.shared.getToken() else {
            self.performSegue(withIdentifier: "goToMainPageVC", sender: nil)
            return
        }
        // API驗證Token登入
        userHelper.shared.tokenLogin(token: token) { result, error in
            // AFError處理
            if let AFerror = error as? AFError{
                switch AFerror {
                case .sessionTaskFailed( _ as URLError):
                    DispatchQueue.main.async {
                        let alert = commonHelper.shared.createAlert(title: textMessage.connectionErrorTitle.rawValue, message: textMessage.connectionErrorMessage.rawValue, buttonTitle: textMessage.confirm.rawValue)
                        self.present(alert, animated: true)
                        return
                    }
                    // 其他錯誤處理
                default:
                    print("Token login error: \(AFerror)")
                }
            }
            
            // 自訂error處理
            if result?.response.success == false, let errorCode = result?.response.errorCode{
                DispatchQueue.main.async {
                    let alert = commonHelper.shared.createAlert(title: textMessage.tokenLoginFailed.rawValue, message: handleResponseError(errorMessage: errorCode), buttonTitle: textMessage.confirm.rawValue)
                    self.present(alert, animated: true)
                }
                return
            }
            
            // 取得UserID
            guard let userID = result?.content?.userID else{
                print("UserID not received!")
                return
            }
            // 存UserID
            userHelper.shared.userID = userID
            // 設定登入狀態
            userHelper.shared.isLoggined = true
            // 前往mainPageVC
            DispatchQueue.main.async {
                self.loadingView.stopAnimating()
                self.performSegue(withIdentifier: "goToMainPageVC", sender: nil)
            }
        }
        userHelper.shared.isLoggined = false
        self.loadingView.stopAnimating()
        self.performSegue(withIdentifier: "goToMainPageVC", sender: nil)
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
