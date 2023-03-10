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
///セクションを制御するためのEnum構造体
enum Section:Int,CaseIterable {
    ///Item
    case basicSetting
    case app
    case user
    ///セクションに対する情報項目(適宜増やしてOK)
    struct SectionItem{
        var sectionTitle:String
        var numberOfRowsInSection:Int
    }
    
    ///アイテムに対して適切なセクション情報を投入
    var Items:SectionItem {
        switch self {
        case .basicSetting:
            let SectionItem = SectionItem(sectionTitle: "基本設定", numberOfRowsInSection: 2)
            return SectionItem
        case .app:
            let SectionItem = SectionItem(sectionTitle: "アプリケーション", numberOfRowsInSection: 2)
            return SectionItem
        case .user:
            let SectionItem = SectionItem(sectionTitle: "ユーザー関連", numberOfRowsInSection: 1)
            return SectionItem
        }
    }
    
}
///セルを制御するためのEnum構造体
enum CellItem:Int,CaseIterable {
    
    ///CellItemを実態化する際にこれを呼び出して正しいCaseを決定すること。
    static func dicidedCase (section:Int,Row:Int) -> CellItem {
        let sectionAndRow = [section,Row]
        switch sectionAndRow {
        case [0,0]:
            return .notification
        case [0,1]:
            return.blockList
        case [1,0]:
            return.inquiry
        case [1,1]:
            return.aboutApp
        case[2,0]:
            return.cancelTheMembership
        default:
            preconditionFailure("Sectionの数が多すぎているか、セルの数が多すぎているためにenum Sectionを要確認")
        }
    }
    
    ///cellの状態
    case notification
    case blockList
    case inquiry
    case aboutApp
    case cancelTheMembership
    
    ///セルに対する情報項目(適宜増やしてOK)
    struct CELLDATA{
        ///セル表示名
        let cellTitle:String
        ///タップしたときの移行画面
        let viewController:UIViewController?
    }
    
    ///アイテムに対して適切なセル情報を投入
    var CELLITEMS:CELLDATA {
        switch self {
        case .notification:
            let CELLDATA = CELLDATA(cellTitle: "通知", viewController: NotificationViewController())
            return CELLDATA
        case .blockList:
            let CELLDATA = CELLDATA(cellTitle: "ブロックリスト", viewController: BlockListViewController())
            return CELLDATA
        case .inquiry:
            let CELLDATA = CELLDATA(cellTitle: "問い合わせ", viewController: NotificationViewController())
            return CELLDATA
        case .aboutApp:
            let CELLDATA = CELLDATA(cellTitle: "このアプリについて", viewController: nil)
            return CELLDATA
        case .cancelTheMembership:
            let CELLDATA = CELLDATA(cellTitle: "メンバーシップの削除", viewController: nil)
            return CELLDATA
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
    
    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
     }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let SECTION = Section(rawValue: section) else {
            ///Section(列挙型)のすべてのCaseの数よりSection数が上回っている（発生しないはず）
            precondition(Section.allCases.count < section)
            return 0
        }
        ///Caseが所持しているセクションが持つセルの数を返却
        return SECTION.Items.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let Section = Section(rawValue: section) else {
            ///Section(列挙型)のすべてのCaseの数よりSection数が上回っている（発生しないはず）
            precondition(Section.allCases.count < section)
            return ""
        }
        ///Caseが所持しているセクションが持つセルのタイトルを返却
        return Section.Items.sectionTitle
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ///カスタムセルをインスタンス化(再利用)
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell", for: indexPath ) as! SideMenuTableViewCell
        ///セル列挙型をIndexpathとSectionに合わせてパターンを決定
        let CELLITEM = CellItem.dicidedCase(section: indexPath.section, Row: indexPath.row)
        ///セルタイトルを設定
        cell.setCell(Item: CELLITEM.CELLITEMS.cellTitle)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ///セル列挙型をIndexpathとSectionに合わせてパターンを決定
        let CELLITEM = CellItem.dicidedCase(section: indexPath.section, Row: indexPath.row)
        
        switch CELLITEM {
        ///通知
        case .notification:
            if let nextViewController = CELLITEM.CELLITEMS.viewController {
                self.delegate?.pushViewController(nextViewController: nextViewController, sideMenuViewcontroller: self)
            } else {
                ///エラーによる強制終了
                preconditionFailure("Cell列挙型の構造体viewControllerに実態が設置されていない")
            }
        ///ブロックリスト
        case .blockList:
            if let nextViewController = CELLITEM.CELLITEMS.viewController {
                self.delegate?.pushViewController(nextViewController: nextViewController, sideMenuViewcontroller: self)
            } else {
                preconditionFailure("Cell列挙型の構造体viewControllerに実態が設置されていない")
            }
        ///問い合わせ
        case .inquiry:
            ///メール送信画面生成及び遷移
            mailViewControllerSet()
        ///アプリについて
        case .aboutApp:
            chooseAboutAppActionSheet(callback: { webPage in
                self.delegate?.pushViewController(nextViewController: WebViewTempleteController(webPageItem: webPage), sideMenuViewcontroller: self)
            }, UIVIEWCONTROLLER: self)
        ///メンバーシップ削除
        case .cancelTheMembership:
            deleteMemberShipActionSheet(UIVIEWCONTROLLER: self)
        }
    }
}
///列挙型に関連する関数
extension SideMenuViewcontroller {
    
    ///メンバーシップ削除のためのFunction
    func deleteMemberShipActionSheet(UIVIEWCONTROLLER:UIViewController){
        let action = actionSheets(twoAtcionTitle1: "テスト的ログアウトボタン", twoAtcionTitle2: "テストデータ大量作成")
        action.showTwoActionSheets(callback: { result in
            switch result {
            case .one:
                do {
                    try Auth.auth().signOut()
                } catch let signOutError as NSError {
                    print("SignOut Error: %@", signOutError)
                }
            case .two:
                let kaihatu = kaihatutouroku()
                let ramdom = "テストデータ\(Int.random(in: 1..<100000))"
                kaihatu.tesutotairyou(callback: { document in
                }, nickName: ramdom, SexNo: 99, ramdomString: ramdom, jibunUID: Auth.auth().currentUser!.uid)
            }
        }, SelfViewController: self)
    }
    
    ///利用規約かプライバシーポリシー選択のためのFunction
    func chooseAboutAppActionSheet(callback: @escaping (WebPage) -> Void,UIVIEWCONTROLLER:UIViewController){
        ///カスタム列挙型インスタンス化
        let webPageTermsOfService = WebPage.TermsOfService
        let webPageprivacyPolicy = WebPage.privacyPolicy
        
        let action = actionSheets(twoAtcionTitle1: webPageprivacyPolicy.info.title, twoAtcionTitle2: webPageTermsOfService.info.title)
        action.showTwoActionSheets(callback: { result in
            switch result {
                ///プライバシーポリシー用のカスタム列挙型を返却
            case .one:
                callback(webPageprivacyPolicy)
                ///利用規約用のカスタム列挙型を返却
            case .two:
                callback(webPageTermsOfService)
            }
        }, SelfViewController: self)
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
            let action = actionSheets(dicidedOrOkOnlyTitle: "メールアカウントが存在しません", message: "問い合わせを行うにはメールアカウントのセットアップが必要です。", buttonMessage: "OK")
            action.okOnlyAction(callback: { result in
                switch result {
                case .one:
                    return
                }
            }, SelfViewController: self)
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
