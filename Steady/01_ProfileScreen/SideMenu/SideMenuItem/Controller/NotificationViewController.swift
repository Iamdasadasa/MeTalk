//
//  NotificationController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/08.
//

import Foundation
import UIKit
import FloatingPanel
import Firebase


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
    
    ///自身の情報
    var SELFUID:String {
        Auth.auth().currentUser!.uid
    }
    ///インスタンス化（View）
    let notificationTableView = UITableView()
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        ///Viewの適用
        self.view = notificationTableView
        self.view.backgroundColor = .white
        notificationTableView.dataSource = self
        notificationTableView.delegate = self
        notificationTableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: "NotificationTableViewCell")
        ///barボタン初期設定
        let barButtonArrowItem = barButtonItem(frame: .zero, BarButtonItemKind: .left)
        barButtonArrowItem.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        let customBarButtonItem = UIBarButtonItem(customView: barButtonArrowItem)
        self.navigationItem.leftBarButtonItem = customBarButtonItem
        ///タイトルラベル追加
        let titleLabel = UILabel()
        titleLabel.text = "通知設定"
        titleLabel.textColor = UIColor.gray
        /// ナビゲーションバーのタイトルビューを設定
        self.navigationItem.titleView = titleLabel
        navigationController?.navigationBar.barTintColor = UIColor.white
        ///スワイプで前画面に戻れるようにする
        edghPanGestureSetting(selfVC: self, selfView: self.view,gestureDirection: .left)
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
        if notificationMenuCellItem == .pushNotification {
            cell.cellFlag = .nortification
            if UserDefaults.standard.bool(forKey: "NotificationToggleKey"){
                cell.switchButton.isOn = true
            } else {
                cell.switchButton.isOn = false
            }
        } else {
            cell.cellFlag = .vibration
            if !UserDefaults.standard.bool(forKey: "vibrationToggleKey"){
                cell.switchButton.isOn = true
            } else {
                cell.switchButton.isOn = false
            }
        }
        cell.delegate = self
        cell.setCell(Item: notificationMenuCellItem.info.celltitle)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}


extension NotificationViewController:nortificationSettingCellDelegate {
    func nortificationSwitchAction(enable: Bool,Switch:UISwitch) {
        ///失敗時のアクションシート
        let flagUpdateFailed = {
            createSheet(for: .Retry(title: "通知設定の更新に失敗しました。"), SelfViewController: self)
        }
        ///通知設定のサーバーインスタンス
        let nortificationSettingSetter = nortificationSetterManager()
        ///現在の本体側の通知設定確認
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            // ユーザーが本体側の通知設定を許可している場合確認
            if granted {
                ///トグルの許可
                if enable {
                    ///サーバーに設定しに行く
                    nortificationSettingSetter.nortificationFlagSetting(callback: { result in
                        ///失敗の場合
                        if !result {
                            DispatchQueue.main.async {
                                ///トグルを戻す
                                Switch.isOn = false
                                ///アクションシート表示
                                flagUpdateFailed()
                                return
                            }
                        } else {
                            ///端末に情報保存
                            UserDefaults.standard.set(true, forKey: "NotificationToggleKey")
                        }
                    }, flag: true, UID:self.SELFUID)

                } else {
                ///トグルの拒否
                    ///サーバーに設定しに行く
                    nortificationSettingSetter.nortificationFlagSetting(callback: { result in
                        ///失敗の場合
                        if !result {
                            DispatchQueue.main.async {
                                ///トグルを戻す
                                Switch.isOn = true
                                ///アクションシート表示
                                flagUpdateFailed()
                                return
                            }
                        } else {
                            ///端末に情報保存
                            UserDefaults.standard.set(true, forKey: "NotificationToggleKey")
                        }
                    }, flag: false, UID:self.SELFUID)
                }
            } else {
                // 本体側の通知設定が拒否されている場合
                DispatchQueue.main.async {
                    Switch.isOn = false
                    createSheet(for: .Alert(title: "プッシュ通知が許可されていません", message: "設定画面に遷移しますか？", buttonMessage: "OK", { result in
                        if result {
                            // アプリの設定画面に誘導する
                            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(appSettings, options: [:], completionHandler: { success in
                                })
                            }
                        }
                    }), SelfViewController: self)

                }
            }
        }
    }
    
    func vibrationSwitchAction(enable: Bool) {
        ///defaults値の関係上falseでバイブレーションが起動するようにする
        if enable {
            UserDefaults.standard.set(false, forKey: "vibrationToggleKey")
        } else {
            UserDefaults.standard.set(true, forKey: "vibrationToggleKey")
        }
    }
}
