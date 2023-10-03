//
//  preloadVC.swift
//  blockShare
//
//  Created by 林裕和 on 2023/10/1.
//

import UIKit
import NVActivityIndicatorView

class preloadVC: UIViewController {

    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.startAnimating()
        // Do any additional setup after loading the view.
        guard let token = userHelper.shared.getToken() else {
            print("get token from keychain failed.")
            self.performSegue(withIdentifier: "goToMainPageVC", sender: nil)
            return
        }
        userHelper.shared.tokenLogin(token: token) { result, error in
            if let error = error{
                print("token login error: \(error)")
                return
            }
            
            guard let userID = result?.content?.userID else{
                print("userID not received!")
                return
            }
            userHelper.shared.userID = userID
            userHelper.shared.isLoggined = true
            DispatchQueue.main.async {
                self.loadingView.stopAnimating()
                self.performSegue(withIdentifier: "goToMainPageVC", sender: nil)
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
