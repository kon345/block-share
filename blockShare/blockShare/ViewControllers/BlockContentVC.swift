//
//  BlockContentVC.swift
//  blockShare
//
//  Created by 林裕和 on 2023/9/14.
//

import UIKit
import SwiftLinkPreview
import Alamofire

class BlockContentVC: UIViewController {
    
    var URLString: String?
    
    enum textMessage: String{
        case dataLoading = "資料載入中..."
        case noTitle = "沒有標題"
        case noDescription = "沒有內文可顯示"
        case getBlockContentFailed = "取得連結內容失敗"
        case pleaseCheckYourConnection = "請檢察網路連線"
        case confirm = "確定"
    }
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var gotoBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var dislikeBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景按鈕樣式處理
        commonHelper.shared.assignbackground(view: self.view, backgroundName: "PageBackground")
        navigationController?.navigationBar.tintColor = UIColor.purple
        commonHelper.shared.setPurpleOrangeBtn(button: gotoBtn)
        
        // 隱藏讚/爛按鈕
        likeBtn.isHidden = true
        dislikeBtn.isHidden = true
        getPreview()
    }
    
    @IBAction func goToBtnPressed(_ sender: Any) {
        guard let urlString = URLString, let URL = URL(string: urlString) else {
            assertionFailure("No URLString!")
            return
        }
        UIApplication.shared.open(URL)
    }
    
    func getPreview(){
        // 確保網址
        guard let urlString = URLString else {
            assertionFailure("No URLString!")
            return
        }
        
        // 嘗試優先使用快取
        if let cached = blockHelper.shared.slp.cache.slp_getCachedResponse(url: urlString){
            showPreviewView(result: cached)
        } else {
            commonHelper.shared.showLoadingView(viewController: self, loadingText: textMessage.dataLoading.rawValue)
            blockHelper.shared.slp.preview(urlString,
                                           onSuccess: showPreviewView,
                                           onError: { error in DispatchQueue.main.async {
                let alert = commonHelper.shared.createAlert(title: textMessage.getBlockContentFailed.rawValue, message: textMessage.pleaseCheckYourConnection.rawValue, buttonTitle: textMessage.confirm.rawValue)
                self.present(alert, animated: true)
            }
                let _ = self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func showPreviewView(result: Response){
        guard let url = result.url else{
            print("url missing!")
            return
        }
        
        // 下載icon
        if let iconURL = result.icon{
            Communicator.shared.downloadImage(urlString: iconURL) { data, error in
                if let error = error{
                    print("download icon error: \(error)")
                    return
                }
                
                guard let data = data else{
                    assertionFailure("cannot get icon image data")
                    return
                }
                
                DispatchQueue.main.async {
                    self.iconImageView.image = UIImage(data: data)?.resize(maxEdge: self.iconImageView.frame.width)
                    self.iconImageView.isHidden = false
                }
            }
        }
        
        // 下載圖片
        if let mainImageURL = result.image{
            Communicator.shared.downloadImage(urlString: mainImageURL) { data, error in
                if let error = error{
                    print("download mainImage error: \(error)")
                    DispatchQueue.main.async {
                        self.mainImageView.image = UIImage(named: "noMainPreviewImage")?.resize(maxEdge: self.mainImageView.frame.width)
                    }
                    return
                }
                
                guard let data = data else{
                    assertionFailure("cannot get icon image data")
                    return
                }
                
                DispatchQueue.main.async {
                    self.mainImageView.image = UIImage(data: data)?.resize(maxEdge: self.mainImageView.frame.width)
                    self.mainImageView.isHidden = false
                    commonHelper.shared.closeLoadingView()
                }
            }
        } else {
            mainImageView.image = UIImage(named: "noMainPreviewImage")?.resize(maxEdge: self.mainImageView.frame.width)
            mainImageView.isHidden = false
        }
        
        // 標題
        if result.title == nil{
            titleLabel.text = textMessage.noTitle.rawValue
        } else {
            titleLabel.text = result.title
        }
        titleLabel.isHidden = false
        
        // 敘述
        if result.description == nil{
            descriptionTextView.text = textMessage.noDescription.rawValue
        } else {
            descriptionTextView.text = result.description
        }
        descriptionTextView.isHidden = false
        
        // 檢查前往
        if UIApplication.shared.canOpenURL(result.url!){
            gotoBtn.isHidden = false
        }
        
        blockHelper.shared.slp.cache.slp_setCachedResponse(url: url.absoluteString, response: result)
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
