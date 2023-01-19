//
//  NotificationController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/08.
//

import Foundation
import UIKit
import FloatingPanel


///セルを制御するためのenum構造体
enum notificationMenuCellItem:Int,CaseIterable{
    ///Item
    case pushNotification
    case vibration
    ///セルに対する情報項目(適宜増やしてOK)
    struct Menudata{
        let celltitle:String
    }
    
    var info:Menudata{
        switch self {
        case .pushNotification:
            let menudata = Menudata(celltitle: "プッシュ通知")
            return menudata
        case .vibration:
            let menudata = Menudata(celltitle: "バイブレーション")
            return menudata
        }
    }
    
}

class NotificationViewController:UIViewController{
    ///Barボタンの設定(NavigationBar)
    var backButtonItem: UIBarButtonItem! // Backボタン
    ///インスタンス化（View）
    let notificationTableView = GeneralTableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        ///Viewの適用
        self.view = notificationTableView
        notificationTableView.dataSource = self
        notificationTableView.delegate = self
        notificationTableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: "NotificationTableViewCell")
        
        ///barボタン初期設定
        backButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(backButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = backButtonItem
        ///タイトルラベル追加
        navigationItem.title = "通知設定"
    }
    
    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
     }
}

///TableView関連の処理
extension NotificationViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationMenuCellItem.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        
        guard let notificationMenuCellItem = notificationMenuCellItem(rawValue: indexPath.row) else {return cell}
        cell.setCell(Item: notificationMenuCellItem.info.celltitle)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
}
