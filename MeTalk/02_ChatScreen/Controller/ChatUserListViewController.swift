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


class ChatUserListViewController:UIViewController{
    ///インスタンス化(View)
    let ChatUserListTableView = GeneralTableView()
    ///インスタンス化(Model)
    let userInfo = UserDataManagedData()
    ///自身のユーザー情報格納変数
    var meInfoData:[String:Any]?
    ///相手のユーザー情報格納変数(現時点でテスト)
    var YouInfoData:[String:Any] = {
        return ["nickName":"うんち"]
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        ///テーブルビューを適用
        self.view = ChatUserListTableView
        self.view.backgroundColor = .black
        ///テーブルビューのデリゲート処理
        ChatUserListTableView.dataSource = self
        ChatUserListTableView.delegate = self
        ///初期状態はセルを選択できないようにする
        ChatUserListTableView.allowsSelection = false
        ///セルの登録
        ChatUserListTableView.register(chatUserListTableViewCell.self, forCellReuseIdentifier: "chatUserListTableViewCell")
        ///自身の情報を取得
        userInfo.userInfoDataGet(callback: { document in
            guard let document = document else {
                return
            }
            ///自身の情報を格納
            self.meInfoData = document
            ///情報が取得できたらセルを選択できるようにする
            self.ChatUserListTableView.allowsSelection = true
        }, UID: Auth.auth().currentUser?.uid)
        
        
        
    }

}

extension ChatUserListViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let menusectionitem = menuSectionItem(rawValue: section) else { return 0 }
        return menusectionitem.info.numberOfRowsInSection
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "chatUserListTableViewCell", for: indexPath ) as! chatUserListTableViewCell

      return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ///本来はここで選んだユーザーの情報を送る
        ///
        guard let meInfoData = meInfoData else {
            return
        }
        ///データモデルおよび遷移先のチャット画面のViewcontrollerをインスタンス化
        let chatdatamanage = ChatDataManagedData()
        let chatViewController = ChatViewController()
        
        ///テスト
        let YouUID:String = {
            if Auth.auth().currentUser?.uid == "708KzmiUBTbZlixgQGh4bOLqQJr2"{
                return "Yd7MNepBxzSc0p7bpp3LjcwSl1h2"
            } else {
                return "708KzmiUBTbZlixgQGh4bOLqQJr2"
            }
        }()
        
        userInfo.userInfoDataGet(callback: { document in
            ///UIDから生成したルームIDを値渡しする
            chatViewController.roomID = chatdatamanage.ChatRoomID(UID1: Auth.auth().currentUser!.uid, UID2: YouUID)
            ///それぞれのユーザー情報を渡す
            chatViewController.MeInfo = meInfoData
            chatViewController.MeUID = Auth.auth().currentUser?.uid
            chatViewController.YouInfo = document
            chatViewController.YouUID = YouUID
            ///UINavigationControllerとして遷移
            let UINavigationController = UINavigationController(rootViewController: chatViewController)
            UINavigationController.modalPresentationStyle = .fullScreen
            self.present(UINavigationController, animated: true, completion: nil)
        }, UID: YouUID)


        
    }
}
