//
//  initialSettingViewcontroller.swift
//  Me2
//
//  Created by KOJIRO MARUYAMA on 2022/01/29.
//

import Foundation
import UIKit
import Firebase
import MessageUI

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
    ///メンバーシップ削除のためのFunction
    func deleteMemberShipActionSheet(UIVIEWCONTROLLER:UIViewController){
        let dialog = actionSheets(title01: "テスト的ログアウトボタン", title02: "テストデータ大量作成")
        dialog.showTwoActionSheets(callback: { actionFLAG in
            switch actionFLAG {
                ///
                case 1:
                    do {
                        try Auth.auth().signOut()
                    } catch let signOutError as NSError {
                        print("SignOut Error: %@", signOutError)
                    }
                ///
                case 2:
                    let kaihatu = kaihatutouroku()
                    let ramdom = "テストデータ\(Int.random(in: 1..<100000))"
                    kaihatu.tesutotairyou(callback: { document in
                        print(document)
                    }, nickName: ramdom, SexNo: 99, ramdomString: ramdom, jibunUID: Auth.auth().currentUser!.uid)
                    
                default:
                    break
            }
        }, SelfViewController: UIVIEWCONTROLLER)
    }
    
    ///利用規約かプライバシーポリシー選択のためのFunction
    func chooseAboutAppActionSheet(callback: @escaping (Int) -> Void,UIVIEWCONTROLLER:UIViewController){
        let dialog = actionSheets(title01: "利用規約", title02: "プライバシーポリシー")
        dialog.showTwoActionSheets(callback: { actionFLAG in
            switch actionFLAG {
                ///画像を表示
                case 1:
                    callback(1)
                ///トーク画面に遷移
                case 2:
                    callback(2)
                default:
                    break
            }
        }, SelfViewController: UIVIEWCONTROLLER)
    }
    
    ///アイテムに対して適切なセル情報を投入
    var info:Menudata {
        switch self {
        case .notification:
            let menudata = Menudata(cellTitle: "通知", viewController: NotificationViewController())
            return menudata
        case .blockList:
            let menudata = Menudata(cellTitle: "ブロックリスト", viewController: BlockListViewController())
            return menudata
        case .inquiry:
            let menudata = Menudata(cellTitle: "問い合わせ", viewController: NotificationViewController())
            return menudata
        case .aboutApp:
            let menudata = Menudata(cellTitle: "このアプリについて", viewController: nil)
            return menudata
        case .cancelTheMembership:
            let menudata = Menudata(cellTitle: "メンバーシップの削除", viewController: nil)
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
    var backButtonItem: UIBarButtonItem! // 戻るボタン
    ///インスタンス化(View)
    let sideMenuTableView = GeneralTableView()

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
        
        switch (indexPath.section,indexPath.row){
        case (1,0):
            ///メール送信画面生成及び遷移
            mailViewControllerSet()
            print("メール問い合わせが押下されました。")
        case(2,0):
            menusectionitem.deleteMemberShipActionSheet(UIVIEWCONTROLLER: self)
        case(1,1):
            menusectionitem.chooseAboutAppActionSheet(callback: {viewFlg in
                self.delegate?.pushViewController(nextViewController: WebViewTempleteController(webPageFlg: viewFlg), sideMenuViewcontroller: self)
            }, UIVIEWCONTROLLER: self)

        default:
        guard let nextViewController = menusectionitem.info.viewController else { return }
            self.delegate?.pushViewController(nextViewController: nextViewController, sideMenuViewcontroller: self)
        }
    }
}

///メール送信画面についてはViewのレイアウトとかも存在しないためここで完結させる
extension SideMenuViewcontroller:MFMailComposeViewControllerDelegate{
    func mailViewControllerSet(){
        //メール送信が可能なら
        if MFMailComposeViewController.canSendMail() {
            //MFMailComposeVCのインスタンス
            let mail = MFMailComposeViewController()
            //MFMailComposeのデリゲート
            mail.mailComposeDelegate = self
            //送り先
            mail.setToRecipients(["penguin.inpuery@gmail.com"])
            //件名
            mail.setSubject("【penguin 問い合わせ】")
            //メッセージ本文
            mail.setMessageBody("【下記に問い合わせ内容を記載してください】", isHTML: false)
            //メールを表示
            self.present(mail, animated: true, completion: nil)
        //メール送信が不可能なら
        } else {
            //アラートで通知
            let dialog = actionSheets(title01: "メールアカウントが存在しません", message: "問い合わせを行うにはメールアカウントのセットアップが必要です。", buttonMessage: "OK")
            dialog.showAlertAction(SelfViewController: self)
        }
    }
    ///エラー処理
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error != nil {
            //送信失敗
            print(error)
        } else {
            switch result {
            case .cancelled:
                //アラートで通知
                let alert = UIAlertController(title: "キャンセルされました", message: nil, preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(dismiss)
                self.present(alert, animated: true, completion: nil)
            case .saved:
                let alert = UIAlertController(title: "下書きが保存されました", message: nil, preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(dismiss)
                self.present(alert, animated: true, completion: nil)
            case .sent:
                let alert = UIAlertController(title: "送信が完了しました", message: nil, preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(dismiss)
                self.present(alert, animated: true, completion: nil)
            default:
                break
            }
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
