//
//  commonHelper.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/15.
//

import Foundation
import UIKit
import NVActivityIndicatorView

// 格子四邊
enum ViewSide {
    case Left, Right, Top, Bottom
}

class commonHelper{
    static let shared = commonHelper()
    private init(){}
    
    enum UIConstants: CGFloat{
        case loadingAnimationPosition = 0
        case loadingAnimationSize = 100
        case loadingLabelTopAnchorConstant = 30
        case loadingLabelFontSize = 40
    }
    
    private var currentOverlayView: UIView?
    
    // 覆蓋等待view
    func showLoadingView(viewController: UIViewController, loadingText: String){
        // 覆蓋view
        let overlayView = UIView(frame: viewController.view.frame)
        viewController.view.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.topAnchor.constraint(equalTo: viewController.view.topAnchor).isActive = true
        overlayView.leftAnchor.constraint(equalTo: viewController.view.leftAnchor).isActive = true
        overlayView.rightAnchor.constraint(equalTo: viewController.view.rightAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor).isActive = true
        overlayView.backgroundColor = UIColor.orange
        
        // 旋轉動畫view
        let loadingAnimation = NVActivityIndicatorView(frame: CGRect(x: UIConstants.loadingAnimationPosition.rawValue, y: UIConstants.loadingAnimationPosition.rawValue, width: UIConstants.loadingAnimationSize.rawValue, height: UIConstants.loadingAnimationSize.rawValue), type: .ballSpinFadeLoader, color: UIColor.white)
        overlayView.addSubview(loadingAnimation)
        loadingAnimation.backgroundColor = UIColor.orange
        loadingAnimation.translatesAutoresizingMaskIntoConstraints = false
        // 置中
        loadingAnimation.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true
        loadingAnimation.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor).isActive = true
        loadingAnimation.startAnimating()
        
        // 文字標籤
        let loadingLabel = UILabel()
        loadingLabel.text = loadingText
        overlayView.addSubview(loadingLabel)
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.topAnchor.constraint(equalTo: loadingAnimation.bottomAnchor, constant: UIConstants.loadingLabelTopAnchorConstant.rawValue).isActive = true
        loadingLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true
        loadingLabel.font = UIFont.systemFont(ofSize: UIConstants.loadingLabelFontSize.rawValue)
        loadingLabel.textColor = UIColor.white
        
        currentOverlayView = overlayView
    }
    
    // 關閉等待view
    func closeLoadingView(){
        guard let currentOverlayView = currentOverlayView else {
            return
        }
        currentOverlayView.removeFromSuperview()
    }
    
    // 單按鈕通知彈窗
    func createAlert(title:String, message: String, buttonTitle: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let close = UIAlertAction(title: buttonTitle, style: .cancel)
        alert.addAction(close)
        return alert
    }
    
    // 跳黑色短暫通知
    func showToastGlobal(message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        
        guard let keyWindow = windowScene.keyWindow else {
            return
        }
        
        let toastWidth: CGFloat = 300
        let toastLabel = UILabel(frame: CGRect(x: keyWindow.frame.width / 2 - toastWidth / 2,
                                               y: keyWindow.frame.height - 250,
                                               width: toastWidth,
                                               height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        keyWindow.addSubview(toastLabel)
        
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
    
    // 加上背景
    // @param viewController
    // @param backgroundName
    func assignbackground(view: UIView, backgroundName: String){
        let background = UIImage(named: backgroundName)
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        view.sendSubviewToBack(imageView)
    }
    
    func setPurpleOrangeBtn(button:UIButton){
        button.tintColor = UIColor.purple
        button.backgroundColor = UIColor(cgColor: CGColor(red: 255/255, green: 193/255, blue: 101/255, alpha: 1))
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.purple.cgColor
    }
}
