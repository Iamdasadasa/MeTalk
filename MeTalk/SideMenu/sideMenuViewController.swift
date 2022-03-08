//
//  initialSettingViewcontroller.swift
//  Me2
//
//  Created by KOJIRO MARUYAMA on 2022/01/29.
//

import Foundation
import UIKit
import Firebase

protocol SideMenuViewControllerDelegate:AnyObject{
    func backButtonTappedDelegate()
}

class SideMenuViewcontroller:UIViewController, UITableViewDelegate, UITableViewDataSource {
    ///Barボタンの設定(NavigationBar)
    var backButtonItem: UIBarButtonItem! // 追加ボタン
    ///インスタンス化(View)
    let sideMenuTableView = SideMenuTableView()
    ///インスタンス化(Model)
    let Item: [[String]] = [
        ["通知","ブロックリスト"],
        ["問い合わせ","このアプリについて"],
        ["退会"]
    ]
    ///デリゲート変数設定
    weak var delegate:SideMenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///barボタン初期設定
        backButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(backButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = backButtonItem
        
        self.view = sideMenuTableView
        self.view.backgroundColor = .black
        sideMenuTableView.dataSource = self
        sideMenuTableView.delegate = self
        sideMenuTableView.register(SideMenuTableViewCell.self, forCellReuseIdentifier: "SideMenuTableViewCell")
        
    }

    
    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
     }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Item.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Item[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title:String = ""
        switch section{
        case 0:
            title = "基本設定"
        case 1:
            title = "アプリケーション"
        case 2:
            title = "ユーザー関連"
        default:
            break
        }
        return title
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell", for: indexPath ) as! SideMenuTableViewCell

        cell.setCell(Item: Item[indexPath.section][indexPath.row])

      return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("SignOut Error: %@", signOutError)
        }
    }


}

