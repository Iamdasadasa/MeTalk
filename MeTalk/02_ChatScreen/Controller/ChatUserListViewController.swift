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
import RealmSwift
import CoreAudio


class ChatUserListViewController:UIViewController, UINavigationControllerDelegate{
    ///インスタンス化(View)
    let CHATUSERLISTTABLEVIEW = GeneralTableView()
    ///RealMからデータを受け取るようの変数
    var itemList: Results<ListUsersInfoLocal>!
    ///インスタンス化(Model)
    let USERDATAMANAGE = UserDataManage()
    let UID = Auth.auth().currentUser?.uid
    ///自身の画像View
    var selfProfileImageView = UIImageView()
    ///自身のユーザー情報格納変数
    var meInfoData:[String:Any]?
    ///追加でロードする際のCount変数
    var loadToLimitCount:Int = 15
    ///重複してメッセージデータを取得しないためのフラグ
    var loadDataLockFlg:Bool = true
    ///追加メッセージデータ関数の起動を停止するフラグ
    var loadDataStopFlg:Bool = false
    ///バックボタンで戻ってきた時に格納してあるUID
    var backButtonUID:String?
    ///トークリストユーザー情報格納配列
    var talkListUsersMock:[TalkListUserStruct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///テーブルビューを適用
        self.view = CHATUSERLISTTABLEVIEW
        self.view.backgroundColor = .black
        ///テーブルビューのデリゲート処理
        CHATUSERLISTTABLEVIEW.dataSource = self
        CHATUSERLISTTABLEVIEW.delegate = self
        ///セルの登録
        CHATUSERLISTTABLEVIEW.register(ChatUserListTableViewCell.self, forCellReuseIdentifier: "ChatUserListTableViewCell")
        ///自身の情報を取得
        userInfoDataGet()
        ///自分の画像を取得してくる
        contentOfFIRStorageGet()
        ///トークリストリスナー
        talkListListner()
        ///タイトルラベル追加
        navigationItem.title = "トークリスト"
    }
}

///↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
///↓↓↓◆◆◆TABLEVIRE◆◆◆↓↓↓
///↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

extension ChatUserListViewController:UITableViewDelegate, UITableViewDataSource{
    ///スクロール中の処理
    /// - Parameters:None
    /// - Returns: None
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ///取得しているユーザーリストの数が15件未満の場合またはデータのロードフラグがTrueは何もしない
        if !loadDataLockFlg || talkListUsersMock.count < 15 {
            return
        }
        //ロードストップのフラグが立っていればリターン
        if loadDataStopFlg {
            return
        }
        ///スクロールの最下層に来た際の処理
        if self.CHATUSERLISTTABLEVIEW.contentOffset.y + self.CHATUSERLISTTABLEVIEW.frame.size.height > self.CHATUSERLISTTABLEVIEW.contentSize.height && scrollView.isDragging{
            loadDataLockFlg = false
            loadToLimitCount = loadToLimitCount + 15
        }
    }
    ///テーブルビューのセクション数設定
    /// - Parameters:None
    /// - Returns: None
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talkListUsersMock.count
    }
    ///テーブルビューの各セルの幅設定
    /// - Parameters:None
    /// - Returns: None
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    ///テーブルビューの各セルの中身の設定
    /// - Parameters:None
    /// - Returns: None
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ///セルのインスタンス化
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUserListTableViewCell", for: indexPath ) as! ChatUserListTableViewCell
        ///Mockのインデックス番号の中身を取得
        let USERINFODATA = self.talkListUsersMock[indexPath.row]
        ///セルUID変数に対してUIDを代入
        cell.cellUID = USERINFODATA.UID
        ///ローカルDBに存在しているUIDを検知
        let REALM = try! Realm()
        
        ///渡したUIDが存在していた場合は追加で情報を上書き
        let extraFlg = chatUserListInfoLocalExstraRegist(Realm: REALM, UID: USERINFODATA.UID, usernickname: USERINFODATA.userNickName, newMessage: USERINFODATA.NewMessage, updateDate: USERINFODATA.upDateDate, listend: USERINFODATA.listend, SendUID: USERINFODATA.sendUID)
        ///渡したUIDが存在していない場合はUIDを含め新規で作成
        if !extraFlg {
            chatUserListInfoLocalDataRegist(Realm: REALM, UID: USERINFODATA.UID, usernickname: USERINFODATA.userNickName, newMessage: USERINFODATA.NewMessage, updateDate: USERINFODATA.upDateDate, listend: USERINFODATA.listend, SendUID: USERINFODATA.sendUID)
        }
        
        ///画像に関してはCell生成の一番最初は問答無用でInitイメージを適用
        cell.talkListUserProfileImageView.image = UIImage(named: "InitIMage")
        ///ユーザーネーム設定処理
        if let nickname = USERINFODATA.userNickName {
            cell.nickNameSetCell(Item: nickname)
        } else {
            ///サーバーに対してユーザーの情報取得
            USERDATAMANAGE.userInfoDataGet(callback: { document in
                guard let document = document else {
                    return
                }
                guard let nickname = document["nickname"] as? String else {
                    return
                }
                ///取得できたらセルの値にセット
                cell.nickNameSetCell(Item: nickname)
            }, UID: USERINFODATA.UID)
        }
        
        //最新メッセージをセルに反映する処理
        let newMessage = USERINFODATA.NewMessage
        cell.newMessageSetCell(Item: newMessage)
        ///ローカルDBインスンス化
        let IMAGELOCALDATASTRUCT = chatUserListLocalImageInfoGet(Realm: REALM, UID: USERINFODATA.UID)
        ///プロファイルイメージをセルに反映(ローカルDB)
        cell.talkListUserProfileImageView.image = IMAGELOCALDATASTRUCT.image ?? UIImage(named: "InitIMage")
        ///サーバーに対して画像取得要求
        USERDATAMANAGE.contentOfFIRStorageGet(callback: { imageStruct in
            ///取得してきた画像がNilでない且つセルに設定してあるUIDとサーバー取得UIDが合致した場合
            ///イメージ画像をオブジェクトにセット
            if imageStruct.image != nil,cell.cellUID == USERINFODATA.UID{
                cell.talkListUserProfileImageView.image = imageStruct.image ?? UIImage(named: "InitIMage")
                ///ローカルDBに取得したデータを上書き保存
                chatUserListLocalImageRegist(Realm: REALM, UID: USERINFODATA.UID, profileImage: imageStruct.image!, updataDate: imageStruct.upDateDate)
            }
        }, UID: USERINFODATA.UID, UpdateTime: IMAGELOCALDATASTRUCT.upDateDate)
         
        ///もしもセルの再利用によってベルアイコンが存在してしまっていたら初期化
        if cell.nortificationImage.image != nil {
            cell.nortificationImage.image = nil
        }
        ///listendがTrue且つ送信者IDが自分でない場合はベルアイコンを表示()
        if USERINFODATA.listend && USERINFODATA.sendUID != UID {
            cell.nortificationImageSetting()
        }
        ///バックボタンで戻ってきた際のUIDがCellのUIDと合致していたらベルアイコンは非表示
        if let backButtonUID = backButtonUID {
            if backButtonUID == USERINFODATA.UID {
                cell.nortificationImage.image = nil
            }
        }
        backButtonUID = nil
        
        return cell
    }
    ///テーブルビューの各セルがタップされた時の処理設定
    /// - Parameters:None
    /// - Returns: None
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ///セル情報を取得
        let cell = tableView.cellForRow(at: indexPath) as! ChatUserListTableViewCell
        ///選んだセルの相手のUIDを取得
        let YouUID = self.talkListUsersMock[indexPath.row].UID
        ///サーバーに対して画像取得要求
        USERDATAMANAGE.userInfoDataGet(callback: { document in
            ///ブロックもしくは退会していた場合
            if let block = document?["UID"] as? String {
                ///アラート用の表示を出す。
                var alertController: UIAlertController!
                alertController = UIAlertController(title: "申し訳ありません",
                                           message: "既にこのユーザーは退会しております",
                                           preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK",
                                               style: .default,
                                               handler: nil))
                self.present(alertController, animated: true)
                ///セル情報の書き換え
                cell.talkListUserNicknameLabel.text = "退会したユーザー"
                cell.talkListUserProfileImageView.image = UIImage(named: "InitIMage")
                cell.talkListUserNewMessage.text = ""
            }
            ///遷移先のチャット画面のViewcontrollerをインスタンス化
            let CHATVIEWCONTROLLER = ChatViewController()
            ///UIDから生成したルームIDを値渡しする
            let CHATDATAMANAGE = ChatDataManagedData()
            let roomID = CHATDATAMANAGE.ChatRoomID(UID1: Auth.auth().currentUser!.uid, UID2: YouUID)
            CHATVIEWCONTROLLER.roomID = roomID
            ///それぞれのユーザー情報を渡す
            CHATVIEWCONTROLLER.MeInfo = self.meInfoData
            CHATVIEWCONTROLLER.MeUID = self.UID
            CHATVIEWCONTROLLER.YouInfo = document
            CHATVIEWCONTROLLER.YouUID = YouUID
            CHATVIEWCONTROLLER.meProfileImage = self.selfProfileImageView.image
            CHATVIEWCONTROLLER.youProfileImage = cell.talkListUserProfileImageView.image
            ///新着ベルアイコンを非表示にする＆該当ユーザーのlisntendをFalseに設定
            cell.nortificationImageRemove()
            self.talkListUsersMock[indexPath.row].listend = false
            ///UINavigationControllerとして遷移
            self.navigationController?.pushViewController(CHATVIEWCONTROLLER, animated: true)
        }, UID: YouUID)
    }
    
    ///横にスワイプした際の処理
    /// - Parameters:None
    /// - Returns: None
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        ///編集処理ボタンの生成
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
          // 編集処理を記述
          print("Editがタップされた")
        // 実行結果に関わらず記述
        completionHandler(true)
        }
        
        ///削除処理ボタンの生成
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
           //削除処理を記述
           print("Deleteがタップされた")

           // 実行結果に関わらず記述
           completionHandler(true)
         }

         // 定義したアクションをセット
         return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
}

///↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
///↓↓↓◆◆◆FIREBASE◆◆◆↓↓↓
///↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

extension ChatUserListViewController {
    ///トークリストのユーザー一覧を取得
    /// - Parameters:
    ///- UID: 取得するトークリスト対象のユーザーUID
    ///- argLatestTime:ローカルに保存してある最終更新日
    ///- limitCount: 取得する件数
    /// - Returns:
    /// -UserUIDUserListMock:取得したユーザーリスト情報
    func talkListUsersDataGet(limitCount:Int,argLastetTime:Date) {
        USERDATAMANAGE.talkListUsersDataGet(callback: { UserUIDUserListMock in
            ///もしも現在のトークユーザーリストのカウントとDBから取得してきたトークユーザーリストのカウントが等しければロードストップのフラグにTrue
            if UserUIDUserListMock.count == self.talkListUsersMock.count {
                self.loadDataStopFlg = true
            }
            ///トークリスト配列を一個ずつ回す
            for data in UserUIDUserListMock {
                ///サーバーから取得したユーザーのUIDがあったらそのIndexNoを取得
                let indexNo = self.talkListUsersMock.firstIndex(where: { $0.UID == data.UID })
                ///配列にある古いデータを削除
                if let indexNo = indexNo{
                    self.talkListUsersMock.remove(at: indexNo)
                }
                ///サーバーから取得したデータを配列に入れ直す
                self.talkListUsersMock.append(TalkListUserStruct(UID: data.UID, userNickName: data.userNickName, profileImage: nil,UpdateDate:data.upDateDate, NewMessage: data.NewMessage, listend: false, sendUID: data.sendUID))
            }
            ///ロードフラグをTrue
            self.loadDataLockFlg = true
        }, UID: UID, argLatestTime: argLastetTime,limitCount: limitCount)
    }
    ///自身の情報を取得
    func userInfoDataGet() {
        ///サーバーに対して画像取得要求
        USERDATAMANAGE.userInfoDataGet(callback: { document in
            ///ドキュメントにデータが入るまではセルを選択できないようにする
            self.CHATUSERLISTTABLEVIEW.allowsSelection = false
            ///データ投入
            self.meInfoData = document
            ///セル選択を可能にする
            self.CHATUSERLISTTABLEVIEW.allowsSelection = true
        }, UID: UID)
    }
    ///自分の画像を取得してくる
    func contentOfFIRStorageGet() {
        ///サーバーに対して画像取得要求
        USERDATAMANAGE.contentOfFIRStorageGet(callback: { imageStruct in
            ///ドキュメントにデータが入るまではセルを選択できないようにする
            self.CHATUSERLISTTABLEVIEW.allowsSelection = false
            ///Nilでない場合はコールバック関数で返ってきたイメージ画像をオブジェクトにセット
            if imageStruct.image != nil {
                self.selfProfileImageView.image = imageStruct.image
            ///コールバック関数でNilが返ってきたら初期画像を設定
            } else {
                self.selfProfileImageView.image = UIImage(named: "InitIMage")
            }
            ///セル選択を可能にする
            self.CHATUSERLISTTABLEVIEW.allowsSelection = true
        }, UID: UID, UpdateTime: ChatDataManagedData.pastTimeGet())
    }
    
    ///トークリストのリアルタイムリスナー
    func talkListListner() {
        ///初回インスタンス時にここでトークリストを更新
        ///ローカルDBにデータが入っている場合はデータをユーザー配列に投入する
        let realm = try! Realm()
        let localDBGetData = realm.objects(ListUsersInfoLocal.self)
        
        for data in localDBGetData {
            self.talkListUsersMock.append(TalkListUserStruct(UID: data.UID!, userNickName: data.userNickName, profileImage: nil,UpdateDate:data.upDateDate!, NewMessage: data.NewMessage!, listend: false, sendUID: data.sendUID!))
        }
        
        ///ユーザートークリスト一覧取得
        self.talkListUsersDataGet(limitCount: 25, argLastetTime: chatUserListInfoLocalLastestTimeGet(Realm: realm))
        var triggerFlgCount:Int = 0
    
        ///リスナー用FireStore変数
        let db = Firestore.firestore()
        guard let uid = UID else {
            return
        }
        ///リスナー処理開始
        db.collection("users").document(uid).collection("TalkUsersList").order(by: "UpdateAt",descending: true).limit(to: 1).addSnapshotListener { (document,err) in
            ///初回起動時でない場合のみ既読バッジオン
            var listend:Bool = true
            if triggerFlgCount == 0 {
                listend = false
            }

            ///エラー処理
            guard let documentSnapShot = document else {
                print(err?.localizedDescription ?? "何らかの原因でトークユーザーリスト内のドキュメントが取得できませんでした")
                return
            }
            ///ドキュメント内の処理
            for documentData in documentSnapShot.documents {
                ///更新日時のタイムスタンプをTimeStamp⇨Date型として受け取る
                guard let timeStamp = documentData["UpdateAt"] as? Timestamp else {
                    return
                }
                let UpdateDate = timeStamp.dateValue()
                
                ///ユーザー配列の名からリスナーで取得されたIDと一致している配列番号を取得
                let indexNo = self.talkListUsersMock.firstIndex(where: {$0.UID == documentData.documentID})

                ///最新メッセージ
                guard let NewMessage = documentData["FirstMessage"] as? String else {
                    print("最新メッセージが変換されませんでした。")
                    return
                }
                ///送信者のUIDを確認
                guard let sendUID = documentData["SendID"] as? String else {
                    print("送信者UID情報が取得できませんでした")
                    return
                }
                ///リスナーで取得された情報がトークリスト配列になかった場合は
                ///新規で配列に投入
                guard let indexNo = indexNo else {
                    self.talkListUsersMock.insert(TalkListUserStruct.init(UID: documentData.documentID, userNickName: nil, profileImage: nil, UpdateDate: UpdateDate, NewMessage: NewMessage, listend: listend, sendUID: sendUID), at: 0)
                    self.CHATUSERLISTTABLEVIEW.reloadData()
                    triggerFlgCount = 1
                    return
                }
                ///更新データなので一旦リムーブして最新データを配列に投入
                self.talkListUsersMock.remove(at: indexNo)
                self.talkListUsersMock.insert(TalkListUserStruct.init(UID: documentData.documentID, userNickName: nil, profileImage: nil, UpdateDate: UpdateDate, NewMessage: NewMessage, listend: listend, sendUID: sendUID), at: 0)
                self.CHATUSERLISTTABLEVIEW.reloadData()
                triggerFlgCount = 1
            }

        }
    }
}
