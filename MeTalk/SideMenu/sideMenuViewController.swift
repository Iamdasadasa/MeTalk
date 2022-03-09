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
    func pushViewController(nextViewController:UIViewController,sideMenuViewcontroller:SideMenuViewcontroller)
}


///セルを制御するためのEnum構造体
enum menuCellItem:Int,CaseIterable {
    ///Item
    case notification
    case blockList
    case inquiry
    case aboutApp
    case cancelTheMembership
    ///セルに対する情報項目(適宜増やしてOK)
    struct  Menudata{
        let cellTitle:String
        let viewController:UIViewController?
    }
    
    ///アイテムに対して適切なセル情報を投入
    var info:Menudata {
        switch self {
        case .notification:
            let menudata = Menudata(cellTitle: "通知", viewController: NotificationController())
            return menudata
        case .blockList:
            let menudata = Menudata(cellTitle: "ブロックリスト", viewController: NotificationController())
            return menudata
        case .inquiry:
            let menudata = Menudata(cellTitle: "問い合わせ", viewController: NotificationController())
            return menudata
        case .aboutApp:
            let menudata = Menudata(cellTitle: "このアプリについて", viewController: NotificationController())
            return menudata
        case .cancelTheMembership:
            let menudata = Menudata(cellTitle: "メンバーシップの削除", viewController: NotificationController())
            return menudata
        }
    }
    
}
///セクションを制御するためのEnum構造体
enum menuSectionItem:Int,CaseIterable {
    ///Item
    case basicSetting
    case app
    case user
    ///セクションに対する情報項目(適宜増やしてOK)
    struct  Menudata{
        var sectionTitle:String
        var numberOfRowsInSection:Int
    }
    ///アイテムに対して適切なセクション情報を投入
    var info:Menudata {
        switch self {
        case .basicSetting:
            let menudata = Menudata(sectionTitle: "基本設定", numberOfRowsInSection: 2)
            return menudata
        case .app:
            let menudata = Menudata(sectionTitle: "アプリケーション", numberOfRowsInSection: 2)
            return menudata
        case .user:
            let menudata = Menudata(sectionTitle: "ユーザー関連", numberOfRowsInSection: 1)
            return menudata
        }
    }
    
}

class SideMenuViewcontroller:UIViewController, UITableViewDelegate, UITableViewDataSource {
    ///Barボタンの設定(NavigationBar)
    var backButtonItem: UIBarButtonItem! // 追加ボタン
    ///インスタンス化(View)
    let sideMenuTableView = SideMenuTableView()

    
    
    let Item: [[String]] = [
        ["通知","ブロックリスト"],
        ["問い合わせ","このアプリについて"],
        ["退会"]
    ]
    ///デリゲート変数設定
    weak var delegate:SideMenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        guard let menu = menuSectionItem(rawValue: 0) else {
//            return
//        }
//        print(menu.info.sectionTitle)
        ///barボタン初期設定
        backButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(backButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = backButtonItem
        
        self.view = sideMenuTableView
        self.view.backgroundColor = .black
        sideMenuTableView.dataSource = self
        sideMenuTableView.delegate = self
        sideMenuTableView.register(SideMenuTableViewCell.self, forCellReuseIdentifier: "SideMenuTableViewCell")
        
    }
    
    ///セルの位置を計算する関数
    func returnNumber(sectionNo:Int,itemNo:Int) -> Int{
        if sectionNo == 0 && itemNo == 0 {
            return 0
        } else if sectionNo == 0 && itemNo == 1 {
            return 1
        } else if sectionNo == 1 && itemNo == 0 {
            return 2
        } else if sectionNo == 1 && itemNo == 1 {
            return 3
        } else if sectionNo == 2 && itemNo == 0 {
            return 4
        } else if sectionNo == 2 && itemNo == 1 {
            return 5
        }
        ///例外
        return 0
    }

    
    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
     }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuSectionItem.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let menusectionitem = menuSectionItem(rawValue: section) else { return 0 }
        return menusectionitem.info.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let menusectionitem = menuSectionItem(rawValue: section) else { return "" }
        return menusectionitem.info.sectionTitle
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell", for: indexPath ) as! SideMenuTableViewCell
        guard let menusectionitem = menuCellItem(rawValue: returnNumber(sectionNo: indexPath.section, itemNo: indexPath.row)) else { return cell }
        
        cell.setCell(Item: menusectionitem.info.cellTitle)

      return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menusectionitem = menuCellItem(rawValue: returnNumber(sectionNo: indexPath.section, itemNo: indexPath.row)) else { return }
        guard let nextViewController = menusectionitem.info.viewController else { return }
//        pushViewController(nextViewController, animated: true)
        self.delegate?.pushViewController(nextViewController: nextViewController, sideMenuViewcontroller: self)
    }


}

