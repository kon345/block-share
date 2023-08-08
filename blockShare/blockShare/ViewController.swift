//
//  ViewController.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/7.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var LoginGroupView: UIView!
    @IBOutlet weak var GroupSelectView: UIView!
    @IBOutlet weak var AccountInputArea: UITextField!
    @IBOutlet weak var PasswordInputArea: UITextField!
    @IBOutlet weak var GroupListTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        GroupSelectView.isHidden = true
    }

    @IBAction func loginBtnPressed(_ sender: Any) {
    }
    
    @IBAction func createGroupBtnPressed(_ sender: Any) {
    }
    @IBAction func groupCodeBtnPressed(_ sender: Any) {
    }
}

