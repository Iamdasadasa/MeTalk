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


class BlockListViewController:UIViewController{
    ///Barボタンの設定(NavigationBar)
    var backButtonItem: UIBarButtonItem! // Backボタン
    ///インスタンス化（View）
    let blockListTableView = GeneralTableView()
    ///インスタンス化（Model）
    let userDataManagedData = UserDataManage()
    let uid = Auth.auth().currentUser?.uid
    let TIMES = TIME()
    ///ブロックリストユーザーID格納配列
    var blockUsersID:[String]? = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///自身のブロックユーザーの一覧を取得
        userDataManagedData.blockUserDataGet(callback: {document in
            self.blockUsersID = document
            self.blockListTableView.reloadData()
        }, UID: uid)

        ///Viewの適用
        self.view = blockListTableView
        blockListTableView.dataSource = self
        blockListTableView.delegate = self
        blockListTableView.register(blockListTableViewCell.self, forCellReuseIdentifier: "BlockListTableViewCell")
        
        ///barボタン初期設定
        backButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(backButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = backButtonItem
        ///タイトルラベル追加
        navigationItem.title = "ブロックリスト"
    }
    
    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
     }

}

///TableView関連の処理
extension BlockListViewController:UITableViewDelegate,UITableViewDataSource{
    ///セクション数--ブロックユーザーの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockUsersID?.count ?? 0
    }
    ///セルの高さ--固定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    ///セルの生成--ブロックユーザーの情報を取得してCELLオブジェクトに投入
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ///対象セルインスタンス化
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockListTableViewCell", for: indexPath) as! blockListTableViewCell
        ///ブロックユーザーIDの配列から取得
        guard let blockUserID = blockUsersID?[indexPath.row] else {return cell}
        ///取得したIDでユーザー情報の取得を開始(ユーザーニックネーム)
        userDataManagedData.userInfoDataGet(callback: {blockUserInfoDoc in
            guard let blockUserInfoDoc = blockUserInfoDoc else {
                print("ブロックリストのユーザー情報が取得できませんでした")
                return
            }
            cell.setCell(Item: blockUserInfoDoc["nickname"] as? String ?? "退会したユーザー")
        }, UID: blockUserID)
        ///取得したIDでユーザー情報の取得を開始(プロフィール画像)
        self.userDataManagedData.contentOfFIRStorageGet(callback: { imageStruct in
            ///Nilでない場合はコールバック関数で返ってきたイメージ画像をオブジェクトにセット
            if imageStruct.image != nil {
                cell.blockUserProfileImageView.image = imageStruct.image
                
            ///コールバック関数でNilが返ってきたら初期画像を設定
            } else {
                cell.blockUserProfileImageView.image = UIImage(named: "InitIMage")
            }
        }, UID: blockUserID, UpdateTime: TIMES.pastTimeGet())
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
}
