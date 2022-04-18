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
    let uid = Auth.auth().currentUser?.uid
    ///自身の画像View
    var selfProfileImageView = UIImageView()
    ///トークリストユーザー情報格納配列
    var talkListUsersUID:[String]? = []
    ///相手のユーザー情報格納変数
    var YouInfoData:[String:Any]?
    ///自身のユーザー情報格納変数
    var meInfoData:[String:Any]?
    ///追加でロードする際のCount変数
    var loadToLimitCount:Int = 15
    ///重複してメッセージデータを取得しないためのフラグ
    var loadDataLockFlg:Bool = true
    ///追加メッセージデータ関数の起動を停止するフラグ
    var loadDataStopFlg:Bool = false
    
    ///トークリストユーザー情報格納配列
    var talkListUsersMock:[UserInfo] = [] {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///テーブルビューを適用
        self.view = ChatUserListTableView
        self.view.backgroundColor = .black
        ///テーブルビューのデリゲート処理
        ChatUserListTableView.dataSource = self
        ChatUserListTableView.delegate = self

        ///セルの登録
        ChatUserListTableView.register(chatUserListTableViewCell.self, forCellReuseIdentifier: "chatUserListTableViewCell")
        ///自身のトークリストのユーザー一覧を取得
//        talkListUsersDataGet(limitCount: loadToLimitCount)
        ///自身の情報を取得
        userInfoDataGet()
        ///自分の画像を取得してくる
        contentOfFIRStorageGet()
        ///トークリストリスナー
        talkListListner()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let talkListUsersUID = talkListUsersUID else {
            return
        }
        ///取得しているユーザーリストの数が15件未満の場合またはデータのロードフラグがTrueは何もしない
        if !loadDataLockFlg {
            return
        }
        
        //ロードストップのフラグが立っていればリターン
        if loadDataStopFlg {
            return
        }
        
        if self.ChatUserListTableView.contentOffset.y + self.ChatUserListTableView.frame.size.height > self.ChatUserListTableView.contentSize.height && scrollView.isDragging{
            print("contentOffset.y:\(self.ChatUserListTableView.contentOffset.y)")
            print("frame.size.height:\(        self.ChatUserListTableView.frame.size.height)")
            print("contentSize.height:\(        self.ChatUserListTableView.contentSize.height)")
            loadDataLockFlg = false
            loadToLimitCount = loadToLimitCount + 15
            self.talkListUsersDataGet(limitCount: loadToLimitCount)
            
        }
     
    }
    
}

extension ChatUserListViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talkListUsersUID?.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      let cell = tableView.dequeueReusableCell(withIdentifier: "chatUserListTableViewCell", for: indexPath ) as! chatUserListTableViewCell
        
        guard let userUID = talkListUsersUID?[indexPath.row] else {
            return cell
        }
        ///取得したIDでユーザー情報の取得を開始(ユーザーニックネーム)
        userInfo.userInfoDataGet(callback: { document in
            guard let document = document else {
                return
            }
            cell.setCell(Item: document["nickname"] as? String ?? "退会したユーザー")
        }, UID: userUID)
        ///取得したIDでユーザー情報の取得を開始(プロフィール画像)
        userInfo.contentOfFIRStorageGet(callback: { image in
            ///Nilでない場合はコールバック関数で返ってきたイメージ画像をオブジェクトにセット
            if image != nil {
                cell.talkListUserProfileImageView.image = image
            ///コールバック関数でNilが返ってきたら初期画像を設定
            } else {
                cell.talkListUserProfileImageView.image = UIImage(named: "InitIMage")
            }
        }, UID: userUID)
        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ///セル情報を取得
        let cell = tableView.cellForRow(at: indexPath) as! chatUserListTableViewCell
        
        ///データモデルおよび遷移先のチャット画面のViewcontrollerをインスタンス化
        let chatdatamanage = ChatDataManagedData()
        let chatViewController = ChatViewController()
        ///選んだセルの相手のUIDを取得
        guard let YouUID = talkListUsersUID?[indexPath.row] else {return}
        

        userInfo.userInfoDataGet(callback: { document in
            ///UIDから生成したルームIDを値渡しする
            chatViewController.roomID = chatdatamanage.ChatRoomID(UID1: Auth.auth().currentUser!.uid, UID2: YouUID)
            ///それぞれのユーザー情報を渡す
            chatViewController.MeInfo = self.meInfoData
            chatViewController.MeUID = self.uid
            chatViewController.YouInfo = document
            chatViewController.YouUID = YouUID
            chatViewController.meProfileImage = self.selfProfileImageView.image
            chatViewController.youProfileImage = cell.talkListUserProfileImageView.image
            ///UINavigationControllerとして遷移
            let UINavigationController = UINavigationController(rootViewController: chatViewController)
            UINavigationController.modalPresentationStyle = .fullScreen
            self.present(UINavigationController, animated: true, completion: nil)
        }, UID: YouUID)
    }
}

///Firebase操作関連
extension ChatUserListViewController {
    ///自身のトークリストのユーザー一覧を取得
    func talkListUsersDataGet(limitCount:Int) {
        userInfo.talkListUsersDataGet(callback: { document in
            
            ///もしも現在のトークユーザーリストのカウントとDBから取得してきたトークユーザーリストのカウントが等しければロードストップのフラグにTrue
            if document.count == self.talkListUsersUID?.count {
                self.loadDataStopFlg = true
            }
            
            ///トークリスト内にいるユーザーID群を取得
            self.talkListUsersUID = document

            ///取得完了したらテーブルビューを更新
            self.ChatUserListTableView.reloadData()
            ///ロードフラグをTrue
            self.loadDataLockFlg = true
            
        }, UID: uid,limitCount: limitCount)
    }
    ///自身の情報を取得
    func userInfoDataGet() {
        userInfo.userInfoDataGet(callback: { document in
            ///ドキュメントにデータが入るまではセルを選択できないようにする
            self.ChatUserListTableView.allowsSelection = false
            ///データ投入
            self.meInfoData = document
            ///セル選択を可能にする
            self.ChatUserListTableView.allowsSelection = true
        }, UID: uid)
    }
    ///自分の画像を取得してくる
    func contentOfFIRStorageGet() {
        userInfo.contentOfFIRStorageGet(callback: { image in
            ///ドキュメントにデータが入るまではセルを選択できないようにする
            self.ChatUserListTableView.allowsSelection = false
            ///Nilでない場合はコールバック関数で返ってきたイメージ画像をオブジェクトにセット
            if image != nil {
                self.selfProfileImageView.image = image
            ///コールバック関数でNilが返ってきたら初期画像を設定
            } else {
                self.selfProfileImageView.image = UIImage(named: "InitIMage")
            }
            ///セル選択を可能にする
            self.ChatUserListTableView.allowsSelection = true
        }, UID: uid)
    }
    ///トークリストのリアルタイムリスナー
    func talkListListner() {
        ///リスナー用FireStore変数
        let db = Firestore.firestore()
        guard let uid = uid else {
            return
        }
        db.collection("users").document(uid).collection("TalkUsersList").addSnapshotListener { (document,err) in
            guard let documentSnapShot = document else {
                print(err?.localizedDescription ?? "何らかの原因でトークユーザーリスト内のドキュメントが取得できませんでした")
                return
            }
            for documentData in documentSnapShot.documents {
                print("documentData.documentID:\(documentData.documentID)")
            }
            ///ここは25件にするのではなく一件にしてトークリストの最初にぶち込むようにしないとユーザーがスクロールしている最中にリスナーが入ったら強制的に25件になって使いがってが悪くなる
            self.talkListUsersDataGet(limitCount: self.loadToLimitCount)
        }
    }
}
