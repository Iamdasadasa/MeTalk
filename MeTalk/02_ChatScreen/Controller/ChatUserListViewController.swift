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
    let databaseRef: DatabaseReference! = Database.database().reference()
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
    var talkListUsersMock:[talkListUserStruct] = []
    
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

        ///取得しているユーザーリストの数が15件未満の場合またはデータのロードフラグがTrueは何もしない
        if !loadDataLockFlg || talkListUsersMock.count < 15 {
            return
        }
        
        //ロードストップのフラグが立っていればリターン
        if loadDataStopFlg {
            return
        }
        
        if self.ChatUserListTableView.contentOffset.y + self.ChatUserListTableView.frame.size.height > self.ChatUserListTableView.contentSize.height && scrollView.isDragging{
            loadDataLockFlg = false
            loadToLimitCount = loadToLimitCount + 15
            self.talkListUsersDataGet(limitCount: loadToLimitCount)
            
        }
     
    }
    
}

extension ChatUserListViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talkListUsersMock.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      let cell = tableView.dequeueReusableCell(withIdentifier: "chatUserListTableViewCell", for: indexPath ) as! chatUserListTableViewCell

        let userInfoData = self.talkListUsersMock[indexPath.row]
        ///画像に関してはCell生成の一番最初は問答無用でInitイメージを適用
        cell.talkListUserProfileImageView.image = UIImage(named: "InitIMage")
        ///ユーザーネーム設定処理
        if let nickName = userInfoData.userNickName {
            cell.nickNameSetCell(Item: nickName)
        } else {
            ///取得したIDでユーザー情報の取得を開始(ユーザーニックネーム)
            userInfo.userInfoDataGet(callback: { document in
                guard let document = document else {
                    cell.nickNameSetCell(Item: "退会したユーザー")
                    return
                }
                cell.nickNameSetCell(Item: document["nickname"] as? String ?? "退会したユーザー")
                self.talkListUsersMock[indexPath.row].userNickName = document["nickname"] as? String ?? "退会したユーザー"
            }, UID: userInfoData.UID)
        }

        //最新メッセージをセルに反映する処理※1
        let newMessage = userInfoData.NewMessage
        cell.newMessageSetCell(Item: newMessage)
        
        ///トーク対象者との最新のメーセージ情報を取得（※1とは別DB）
        let talkRoomID = ChatDataManagedData().ChatRoomID(UID1: Auth.auth().currentUser!.uid, UID2: userInfoData.UID)
        
        databaseRef.child("Chat").child(talkRoomID).queryLimited(toLast: 1).queryOrdered(byChild: "Date").observe(.childAdded) { (snapshot) in
            if let postDict = snapshot.value as? [String: Any] {

                let message = postDict["message"] as? String
                let senderID = postDict["sender"] as? String
                let date = postDict["Date"] as? String
                let messageID = postDict["messageID"] as? String
                let listend = postDict["listend"] as? Bool ?? false
                
                ///もしも送信者IDが自分のIDではなく、listendの値がFalseの時新着ベルアイコンを表示
                if !listend && senderID != self.uid {
                    print(indexPath.row)
                    cell.nortificationImageSetting()
                }
            }
        }
        
        ///プロファイルイメージをセルに反映
        if let profilaImage = userInfoData.profileImage {
            cell.talkListUserProfileImageView.image = profilaImage
        } else {
            ///取得したIDでユーザー情報の取得を開始(プロフィール画像)
            userInfo.contentOfFIRStorageGet(callback: { image in
                ///Nilでない場合はコールバック関数で返ってきたイメージ画像をオブジェクトにセット
                if image != nil {
                    cell.talkListUserProfileImageView.image = image
                    self.talkListUsersMock[indexPath.row].profileImage = image
                ///コールバック関数でNilが返ってきたら初期画像を設定
                } else {
                    cell.talkListUserProfileImageView.image = UIImage(named: "InitIMage")
                    self.talkListUsersMock[indexPath.row].profileImage = UIImage(named: "InitIMage")
                }
            }, UID: userInfoData.UID)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ///セル情報を取得
        let cell = tableView.cellForRow(at: indexPath) as! chatUserListTableViewCell
        
        ///データモデルおよび遷移先のチャット画面のViewcontrollerをインスタンス化
        let chatdatamanage = ChatDataManagedData()
        let chatViewController = ChatViewController()
        ///選んだセルの相手のUIDを取得
        let YouUID = self.talkListUsersMock[indexPath.row].UID

        userInfo.userInfoDataGet(callback: { document in
            ///UIDから生成したルームIDを値渡しする
            let roomID = chatdatamanage.ChatRoomID(UID1: Auth.auth().currentUser!.uid, UID2: YouUID)
            chatViewController.roomID = roomID
            ///それぞれのユーザー情報を渡す
            chatViewController.MeInfo = self.meInfoData
            chatViewController.MeUID = self.uid
            chatViewController.YouInfo = document
            chatViewController.YouUID = YouUID
            chatViewController.meProfileImage = self.selfProfileImageView.image
            chatViewController.youProfileImage = cell.talkListUserProfileImageView.image
            ///新着ベルアイコンを非表示にする＆最新メッセージのlisntendをFalseに設定
            cell.nortificationImageRemove()

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
        userInfo.talkListUsersDataGet(callback: { UserUIDUserListMock in

            ///もしも現在のトークユーザーリストのカウントとDBから取得してきたトークユーザーリストのカウントが等しければロードストップのフラグにTrue
            if UserUIDUserListMock.count == self.talkListUsersMock.count {
                self.loadDataStopFlg = true
            }
            
            self.talkListUsersMock = UserUIDUserListMock
            
            ///ロードフラグをTrue
            self.loadDataLockFlg = true
            
            self.ChatUserListTableView.reloadData()
            
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
        ///初回インスタンス時にここでトークリストを更新
        self.talkListUsersDataGet(limitCount: 25)
        ///リスナー用FireStore変数
        let db = Firestore.firestore()
        guard let uid = uid else {
            return
        }


        db.collection("users").document(uid).collection("TalkUsersList").order(by: "UpdateAt",descending: true).limit(to: 1).addSnapshotListener { (document,err) in
            guard let documentSnapShot = document else {
                print(err?.localizedDescription ?? "何らかの原因でトークユーザーリスト内のドキュメントが取得できませんでした")
                return
            }
            
            for documentData in documentSnapShot.documents {
                print("documentData.documentID:\(documentData.documentID)")
                ///更新日時のタイムスタンプをTimeStamp⇨Date型として受け取る
                guard let timeStamp = documentData["UpdateAt"] as? Timestamp else {
                    return
                }
                let UpdateDate = timeStamp.dateValue()
                
                let indexNo = self.talkListUsersMock.firstIndex(where: {$0.UID == documentData.documentID})
                
                ///最新メッセージ
                guard let NewMessage = documentData["FirstMessage"] as? String else {
                    print("最新メッセージが変換されませんでした。")
                    return
                }
                
                guard let indexNo = indexNo else {
                    self.talkListUsersMock.insert(talkListUserStruct.init(UID: documentData.documentID, userNickName: nil, profileImage: nil, UpdateDate: UpdateDate, NewMessage:NewMessage), at: 0)
                    self.ChatUserListTableView.reloadData()
                    return
                }

                self.talkListUsersMock.remove(at: indexNo)
                self.talkListUsersMock.insert(talkListUserStruct.init(UID: documentData.documentID, userNickName: nil, profileImage: nil, UpdateDate: UpdateDate, NewMessage: NewMessage), at: 0)
                self.ChatUserListTableView.reloadData()
            }

        }
    }
}
