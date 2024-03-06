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
            return.adminViewController
        default:
            preconditionFailure("Sectionの数が多すぎているか、セルの数が多すぎているためにenum Sectionを要確認")
        }
    }
    
    ///cellの状態
    case notification
    case blockList
    case inquiry
    case aboutApp
    case adminViewController
    
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
        case .adminViewController:
            let CELLDATA = CELLDATA(cellTitle: "管理者画面", viewController: AdminMenuViewController())
            return CELLDATA
        }
    }
}

class SideMenuViewcontroller:UIViewController, UITableViewDelegate, UITableViewDataSource {
    ///Barボタンの設定(NavigationBar)
    var backButtonItem: UIBarButtonItem! // 戻るボタン
    ///インスタンス化(View)
    let sideMenuTableView = UITableView()
    var SELFINFO:RequiredProfileInfoLocalData ///自身の情報
    var adminEnabled:Bool = false

    ///デリゲート変数設定
    weak var delegate:SideMenuViewControllerDelegate?
    
    init(SELFINFO:RequiredProfileInfoLocalData) {

        self.SELFINFO = SELFINFO
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        ///barボタン初期設定
        let barButtonArrowItem = barButtonItem(frame: .zero, BarButtonItemKind: .left)
        barButtonArrowItem.addTarget(self, action: #selector(backButtonPressed(_:)), for: .touchUpInside)
        let customBarButtonItem = UIBarButtonItem(customView: barButtonArrowItem)
        self.navigationItem.leftBarButtonItem = customBarButtonItem
        
        self.view = sideMenuTableView
        self.view.backgroundColor = .white
        sideMenuTableView.dataSource = self
        sideMenuTableView.delegate = self
        sideMenuTableView.register(SideMenuTableViewCell.self, forCellReuseIdentifier: "SideMenuTableViewCell")
        ///管理者確認
        adminMenu()
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
    
    // セクションの背景とテキストの色を変更する
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        // テキスト色を変更する
        header.textLabel?.textColor = .gray
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath == [2,0] else {
            return 50
        }
        if adminEnabled {
            return 50
        } else {
            return  0
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ///カスタムセルをインスタンス化(再利用)
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell", for: indexPath ) as! SideMenuTableViewCell
        ///セル列挙型をIndexpathとSectionに合わせてパターンを決定
        let CELLITEM = CellItem.dicidedCase(section: indexPath.section, Row: indexPath.row)
        ///セルタイトルを設定
        cell.setCell(Item: CELLITEM.CELLITEMS.cellTitle)
        ///セルの選択状態を拒否
        cell.selectionStyle = .none
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
        ///管理者画面
        case .adminViewController:
            if let nextViewController = CELLITEM.CELLITEMS.viewController {
                self.delegate?.pushViewController(nextViewController: nextViewController, sideMenuViewcontroller: self)
            } else {
                preconditionFailure("Cell列挙型の構造体viewControllerに実態が設置されていない")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .white
    }
    
    
}
///列挙型に関連する関数
extension SideMenuViewcontroller {
    
    ///メンバーシップ削除のためのFunction
    func deleteMemberShipActionSheet(UIVIEWCONTROLLER:UIViewController){
        createSheet(for: .Options(["テスト的ログアウトボタン","テストデータ大量作成"], { result in
            switch result {
            case 0:
                do {
                    try Auth.auth().signOut()
                } catch let signOutError as NSError {
                    print("SignOut Error: %@", signOutError)
                }
                preconditionFailure("強制退会")
            case 1:
                let kaihatu = kaihatutouroku()
                let ramdom = "テストデータ\(Int.random(in: 1..<100000))"
                kaihatu.tesutotairyou(callback: { document in
                }, nickName: ramdom, SexNo: 99, ramdomString: ramdom, jibunUID: Auth.auth().currentUser!.uid)
            default:
                return
            }
        }), SelfViewController: self)
//        let action = actionSheets(twoAtcionTitle1: "テスト的ログアウトボタン", twoAtcionTitle2: "テストデータ大量作成")
//        action.showTwoActionSheets(callback: { result in
//            switch result {
//            case .one:
//                do {
//                    try Auth.auth().signOut()
//                } catch let signOutError as NSError {
//                    print("SignOut Error: %@", signOutError)
//                }
//            case .two:
//                let kaihatu = kaihatutouroku()
//                let ramdom = "テストデータ\(Int.random(in: 1..<100000))"
//                kaihatu.tesutotairyou(callback: { document in
//                }, nickName: ramdom, SexNo: 99, ramdomString: ramdom, jibunUID: Auth.auth().currentUser!.uid)
//            }
//        }, SelfViewController: self)
    }
    
    ///利用規約かプライバシーポリシー選択のためのFunction
    func chooseAboutAppActionSheet(callback: @escaping (WebPage) -> Void,UIVIEWCONTROLLER:UIViewController){
        ///カスタム列挙型インスタンス化
        let webPageTermsOfService = WebPage.TermsOfService
        let webPageprivacyPolicy = WebPage.privacyPolicy
        
        createSheet(for: .Options([webPageprivacyPolicy.info.title,webPageTermsOfService.info.title], { result in
            switch result {
            case 0:
                callback(webPageprivacyPolicy)
            case 1:
                callback(webPageTermsOfService)
            default:
                return
            }
        }), SelfViewController: self)
        
//        let action = actionSheets(twoAtcionTitle1: webPageprivacyPolicy.info.title, twoAtcionTitle2: webPageTermsOfService.info.title)
//        action.showTwoActionSheets(callback: { result in
//            switch result {
//                ///プライバシーポリシー用のカスタム列挙型を返却
//            case .one:
//                callback(webPageprivacyPolicy)
//                ///利用規約用のカスタム列挙型を返却
//            case .two:
//                callback(webPageTermsOfService)
//            }
//        }, SelfViewController: self)
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
            createSheet(for: .Retry(title: "メールアカウントが存在しません"), SelfViewController: self)
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

//管理者メニュー表示
extension SideMenuViewcontroller {
    func adminMenu() {
        let defaults = UserDefaults.standard

        if defaults.bool(forKey: "admin") {
            self.adminEnabled = true
            self.sideMenuTableView.reloadData()
        }
    }
}
