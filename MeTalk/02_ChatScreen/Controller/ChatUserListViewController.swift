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
    //Realmのテーブルをインスタンス化
    let  listUsersImageLocal = ListUsersImageLocal()
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
    ///バックボタンで戻ってきた時に格納してあるUID
    var backButtonUID:String?
    
    ///Barボタンの設定(NavigationBar)
    var editItem: UIBarButtonItem! // Backボタン
    
    ///トークリストユーザー情報格納配列
    var talkListUsersMock:[talkListUserStruct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///テーブルビューを適用
        self.view = CHATUSERLISTTABLEVIEW
        self.view.backgroundColor = .black
        ///テーブルビューのデリゲート処理
        CHATUSERLISTTABLEVIEW.dataSource = self
        CHATUSERLISTTABLEVIEW.delegate = self

        ///セルの登録
        CHATUSERLISTTABLEVIEW.register(CHATUSERLISTTABLEVIEWCell.self, forCellReuseIdentifier: "CHATUSERLISTTABLEVIEWCell")
        ///自身の情報を取得
        userInfoDataGet()
        ///自分の画像を取得してくる
        contentOfFIRStorageGet()
        ///トークリストリスナー
        talkListListner()
        ///タイトルラベル追加
        navigationItem.title = "トークリスト"
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
        
        if self.CHATUSERLISTTABLEVIEW.contentOffset.y + self.CHATUSERLISTTABLEVIEW.frame.size.height > self.CHATUSERLISTTABLEVIEW.contentSize.height && scrollView.isDragging{
            loadDataLockFlg = false
            loadToLimitCount = loadToLimitCount + 15
            
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
     print("呼ばれました")
      let cell = tableView.dequeueReusableCell(withIdentifier: "CHATUSERLISTTABLEVIEWCell", for: indexPath ) as! CHATUSERLISTTABLEVIEWCell

        ///Mockのインデックス番号の中身を取得
        var userInfoData = self.talkListUsersMock[indexPath.row]
        ///セルUID変数に対してUIDを代入
        cell.cellUID = userInfoData.UID
        
        ///ローカルDBに存在しているUIDを検知
        let realm = try! Realm()
        ///存在していた場合は追加で情報を上書き
        let extraFlg = chatUserListInfoLocalExstraRegist(Realm: realm, UID: userInfoData.UID, usernickname: userInfoData.userNickName, newMessage: userInfoData.NewMessage, updateDate: userInfoData.upDateDate, listend: userInfoData.listend, SendUID: userInfoData.sendUID)
        ///存在していない場合はUIDを含め新規で作成
        if !extraFlg {
            chatUserListInfoLocalDataRegist(Realm: realm, UID: userInfoData.UID, usernickname: userInfoData.userNickName, newMessage: userInfoData.NewMessage, updateDate: userInfoData.upDateDate, listend: userInfoData.listend, SendUID: userInfoData.sendUID)
        }

        ///画像に関してはCell生成の一番最初は問答無用でInitイメージを適用
        cell.talkListUserProfileImageView.image = UIImage(named: "InitIMage")
        ///ユーザーネーム設定処理
        if let nickname = userInfoData.userNickName {
            cell.nickNameSetCell(Item: nickname)
        } else {
            ///nicknameを取得
            userInfo.userInfoDataGet(callback: { document in
                guard let document = document else {
                    return
                }
                guard let nickname = document["nickname"] as? String else {
                    return
                }
                
                cell.nickNameSetCell(Item: nickname)
                
            }, UID: userInfoData.UID)
        }
        
        
        //最新メッセージをセルに反映する処理※1
        let newMessage = userInfoData.NewMessage
        cell.newMessageSetCell(Item: newMessage)

        ///ローカルDBインスンス化
        let imageLocalDataStruct = chatUserListLocalImageInfoGet(Realm: realm, UID: userInfoData.UID)
        ///プロファイルイメージをセルに反映(ローカルDB)
        cell.talkListUserProfileImageView.image = imageLocalDataStruct.image ?? UIImage(named: "InitIMage")
        
            ///取得したIDでユーザー情報の取得を開始(プロフィール画像)
            userInfo.contentOfFIRStorageGet(callback: { imageStruct in
                ///Nilでない場合はコールバック関数で返ってきたイメージ画像をオブジェクトにセット
                if imageStruct.image != nil,cell.cellUID == userInfoData.UID{
                    cell.talkListUserProfileImageView.image = imageStruct.image ?? UIImage(named: "InitIMage")
                    ///ローカルDBに取得したデータを上書き保存
                    self.chatUserListLocalImageRegist(Realm: realm, UID: userInfoData.UID, profileImage: imageStruct.image!, updataDate: imageStruct.upDateDate)

                ///コールバック関数でNilが返ってきたらローカルデータ画像もしくは初期画像を設定
                }
            }, UID: userInfoData.UID, UpdateTime: imageLocalDataStruct.upDateDate)
         
        ///もしもセルの再利用によってベルアイコンが存在してしまっていたら初期化
        if cell.nortificationImage.image != nil {
            cell.nortificationImage.image = nil
        }
        ///listendがTrue且つ送信者IDが自分でない場合はベルアイコンを表示()
        if userInfoData.listend && userInfoData.sendUID != uid {
            cell.nortificationImageSetting()
        }
        
        ///バックボタンで戻ってきた際のUIDがCellのUIDと合致していたらベルアイコンは非表示
        if let backButtonUID = backButtonUID {
            if backButtonUID == userInfoData.UID {
                cell.nortificationImage.image = nil

            }
        }
        backButtonUID = nil
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ///セル情報を取得
        let cell = tableView.cellForRow(at: indexPath) as! CHATUSERLISTTABLEVIEWCell
        
        ///データモデルおよび遷移先のチャット画面のViewcontrollerをインスタンス化
        let chatdatamanage = ChatDataManagedData()
        let chatViewController = ChatViewController()
        ///選んだセルの相手のUIDを取得
        let YouUID = self.talkListUsersMock[indexPath.row].UID

        userInfo.userInfoDataGet(callback: { document in
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
            ///新着ベルアイコンを非表示にする＆該当ユーザーのlisntendをFalseに設定
            cell.nortificationImageRemove()
            self.talkListUsersMock[indexPath.row].listend = false

            ///UINavigationControllerとして遷移
            let UIViewController = chatViewController
            self.navigationController?.pushViewController(UIViewController, animated: true)
            
            
        }, UID: YouUID)
    }
    
    ///横スワイプした際の処理
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
          // 編集処理を記述
          print("Editがタップされた")

        // 実行結果に関わらず記述
        completionHandler(true)
        }
    
        // 削除処理
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

///Firebase操作関連
extension ChatUserListViewController {
    ///自身のトークリストのユーザー一覧を取得
    func talkListUsersDataGet(limitCount:Int,argLastetTime:Date) {
        userInfo.talkListUsersDataGet(callback: { UserUIDUserListMock in

            ///もしも現在のトークユーザーリストのカウントとDBから取得してきたトークユーザーリストのカウントが等しければロードストップのフラグにTrue
            if UserUIDUserListMock.count == self.talkListUsersMock.count {
                self.loadDataStopFlg = true
            }
            
            for data in UserUIDUserListMock {
//                現在のトークリスト配列にサーバーから取得したユーザーのUIDがあったらそのIndexNoを取得
                let indexNo = self.talkListUsersMock.firstIndex(where: { $0.UID == data.UID })
                
                if let indexNo = indexNo{
                    self.talkListUsersMock.remove(at: indexNo)
                }
                
                self.talkListUsersMock.append(talkListUserStruct(UID: data.UID, userNickName: data.userNickName, profileImage: nil,UpdateDate:data.upDateDate, NewMessage: data.NewMessage, listend: false, sendUID: data.sendUID))
            }
            
            ///ロードフラグをTrue
            self.loadDataLockFlg = true
            
        }, UID: uid, argLatestTime: argLastetTime,limitCount: limitCount)
    }
    ///自身の情報を取得
    func userInfoDataGet() {
        userInfo.userInfoDataGet(callback: { document in
            ///ドキュメントにデータが入るまではセルを選択できないようにする
            self.CHATUSERLISTTABLEVIEW.allowsSelection = false
            ///データ投入
            self.meInfoData = document
            ///セル選択を可能にする
            self.CHATUSERLISTTABLEVIEW.allowsSelection = true
        }, UID: uid)
    }
    ///自分の画像を取得してくる
    func contentOfFIRStorageGet() {
        userInfo.contentOfFIRStorageGet(callback: { imageStruct in
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
        }, UID: uid, UpdateTime: ChatDataManagedData.pastTimeGet())
    }
    ///トークリストのリアルタイムリスナー
    
    func talkListListner() {
        ///初回インスタンス時にここでトークリストを更新
        ///ローカルDBにデータが入っている場合はデータをユーザー配列に投入する
        let realm = try! Realm()
        
        let localDBGetData = realm.objects(ListUsersInfoLocal.self)

        for data in localDBGetData {

            self.talkListUsersMock.append(talkListUserStruct(UID: data.UID!, userNickName: data.userNickName, profileImage: nil,UpdateDate:data.upDateDate!, NewMessage: data.NewMessage!, listend: false, sendUID: data.sendUID!))
        }
        
        self.talkListUsersDataGet(limitCount: 25, argLastetTime: chatUserListInfoLocalLastestTimeGet(Realm: realm))
        var triggerFlgCount:Int = 0
    
        ///リスナー用FireStore変数
        let db = Firestore.firestore()
        guard let uid = uid else {
            return
        }

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
                
                guard let indexNo = indexNo else {
                    let realm = try! Realm()
                    self.chatUserListInfoLocalExstraRegist(Realm: realm, UID: documentData.documentID, usernickname: nil, newMessage: NewMessage, updateDate: UpdateDate, listend: false, SendUID: sendUID)
                    self.CHATUSERLISTTABLEVIEW.reloadData()
                    triggerFlgCount = 1
                    return
                }

                self.talkListUsersMock.remove(at: indexNo)
                self.talkListUsersMock.insert(talkListUserStruct.init(UID: documentData.documentID, userNickName: nil, profileImage: nil, UpdateDate: UpdateDate, NewMessage: NewMessage, listend: listend, sendUID: sendUID), at: 0)
                self.CHATUSERLISTTABLEVIEW.reloadData()
                triggerFlgCount = 1

            }

        }
    }
}


extension ChatUserListViewController {
    ///ローカルDBへの新規データ登録
    func chatUserListInfoLocalDataRegist(Realm:Realm,UID:String,usernickname:String?,newMessage:String,updateDate:Date,listend:Bool,SendUID:String){
        let realm = Realm

        let UserListLocalObject = ListUsersInfoLocal()
        
        UserListLocalObject.UID = UID
        UserListLocalObject.userNickName = usernickname
        UserListLocalObject.NewMessage = newMessage
        UserListLocalObject.upDateDate = updateDate
        UserListLocalObject.listend = listend
        UserListLocalObject.sendUID = SendUID
        
        try! realm.write {
             realm.add(UserListLocalObject)
        }
    }
    
    ///ローカルDBから検索して追加データ登録
    func chatUserListInfoLocalExstraRegist(Realm:Realm,UID:String,usernickname:String?,newMessage:String,updateDate:Date,listend:Bool,SendUID:String) -> Bool{
        let realm = Realm
        
        let localDBGetData = realm.objects(ListUsersInfoLocal.self)
        
        // UIDで検索
        let UID = UID
        let predicate = NSPredicate(format: "UID == %@", UID)
        
        guard let user = localDBGetData.filter(predicate).first else {
            return false
        }
        // UID以外のデータを更新する
        do{
          try realm.write{
              user.userNickName = usernickname
              user.NewMessage = newMessage
              user.upDateDate = updateDate
              user.listend = listend
              user.sendUID = SendUID
          }
        }catch {
          print("Error \(error)")
        }
        return true
    }
    
    ///ローカルDBに保存してあるデータの中で最新の時間を取得して返す
    func chatUserListInfoLocalLastestTimeGet(Realm:Realm) -> Date{
        let realm = Realm
        
        let localDBGetData = realm.objects(ListUsersInfoLocal.self).sorted(byKeyPath: "upDateDate", ascending: false)

        let result = localDBGetData.first
//        もしも一件もローカルにデータが入っていなかった時はものすごい前の時間を設定して値を返す
        guard let result = result?.upDateDate else {
            return ChatDataManagedData.pastTimeGet()
        }
        return result
    }
    
    ///ローカルDBにイメージを保存
    func chatUserListLocalImageRegist(Realm:Realm,UID:String,profileImage:UIImage,updataDate:Date){
        let realm = Realm
        
        //UserDefaults のインスタンス生成
        let userDefaults = UserDefaults.standard
        
        //②保存するためのパスを作成する
        let documentDirectoryFileURL = userDefaultsImageDataPathCreate(UID: UID)
        
        let localDBGetData = realm.objects(ListUsersImageLocal.self)
        
        // UIDで検索
        let UID = UID
        let predicate = NSPredicate(format: "UID == %@", UID)
        
        ///もしも既にUIDがローカルDBに存在していたらUID以外の情報を更新保存
        if let imageData = localDBGetData.filter(predicate).first{
            // UID以外のデータを更新する
            do{
              try realm.write{
                  imageData.profileImageURL  = documentDirectoryFileURL.absoluteString
                  imageData.updataDate = updataDate
              }
            }catch {
              print("Error \(error)")
            }
        ///存在していない場合新規なのでUIDも含め新規保存
        } else {
            
            do{
                try realm.write{
                    listUsersImageLocal.profileImageURL = documentDirectoryFileURL.absoluteString
                    listUsersImageLocal.updataDate = updataDate
                    listUsersImageLocal.UID = UID
                }
            }catch{
                print("画像の保存に失敗しました")
            }
            try! realm.write{realm.add(listUsersImageLocal)}
            
        }
        

         //pngで保存する場合
        let pngImageData = profileImage.pngData()
         do {
             try pngImageData!.write(to: documentDirectoryFileURL)
             //②「Documents下のパス情報をUserDefaultsに保存する」
             userDefaults.set(documentDirectoryFileURL, forKey: "\(UID)_profileimage")
         } catch {
             //エラー処理
             print("エラー")
         }
    }
    
    ///ローカルDBの画像情報を取得してくる
    func chatUserListLocalImageInfoGet(Realm:Realm,UID:String) -> listUserImageStruct{

        let realm = Realm
        let localDBGetData = realm.objects(ListUsersImageLocal.self)
        
        // UIDで検索
        let UID = UID
        let predicate = NSPredicate(format: "UID == %@", UID)
        
        guard let imageData = localDBGetData.filter(predicate).first else {
            ///ローカルデータに入っていなかったら初期時間及び画像をNilで返却
            let newUserimageStruct = listUserImageStruct(UID: UID, UpdateDate: ChatDataManagedData.pastTimeGet(), UIimage: nil)
            return newUserimageStruct
        }

        
        ///URL型にキャスト
        let fileURL = userDefaultsImageDataPathCreate(UID: UID)
        ///パス型に変換
        let filePath = fileURL.path
        
        if FileManager.default.fileExists(atPath: filePath) {
           print(filePath)
        }
        
        let imageStrcut = listUserImageStruct(UID: UID, UpdateDate: imageData.updataDate!, UIimage: UIImage(contentsOfFile: filePath))
        
        return imageStrcut
        
    }
}
