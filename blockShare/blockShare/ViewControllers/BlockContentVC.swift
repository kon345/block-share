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
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var gotoBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var dislikeBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        hideAllUI()
        getPreview()
    }
    
    @IBAction func goToBtnPressed(_ sender: Any) {
        guard let urlString = URLString, let URL = URL(string: urlString) else {
            assertionFailure("No URLString!")
            return
        }
        UIApplication.shared.open(URL)
    }
    
    @IBAction func likeBtnPressed(_ sender: Any) {
    }
    
    @IBAction func dislikeBtnPressed(_ sender: Any) {
    }
    
    func hideAllUI(){
        titleLabel.isHidden = true
        iconImageView.isHidden = true
        mainImageView.isHidden = true
        gotoBtn.isHidden = true
        descriptionTextView.isHidden = true
        likeBtn.isHidden = true
        dislikeBtn.isHidden = true
    }
    
    func getPreview(){
        // 確保網址
        guard let urlString = URLString else {
            assertionFailure("No URLString!")
            return
        }
        let slp = SwiftLinkPreview(session: URLSession.shared,
                                   workQueue: SwiftLinkPreview.defaultWorkQueue,
                                   responseQueue: DispatchQueue.main,
                                   cache: DisabledCache.instance)
        
        _ = slp.preview(urlString,
                        onSuccess: showPreviewView,
                        onError: { error in print("\(error)")})
        
    }
    
    func showPreviewView(result: Response){
        print("\(result)")
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
                }
            }
        } else {
            mainImageView.image = UIImage(named: "noMainPreviewImage")?.resize(maxEdge: self.mainImageView.frame.width)
            mainImageView.isHidden = false
        }
        
        // 標題
        titleLabel.text = result.title
        titleLabel.isHidden = false
        // 敘述
        descriptionTextView.text = result.description
        descriptionTextView.isHidden = false
        
        // 檢查前往
        if UIApplication.shared.canOpenURL(result.url!){
            gotoBtn.isHidden = false
        }
        
        likeBtn.isHidden = false
        dislikeBtn.isHidden = false
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
