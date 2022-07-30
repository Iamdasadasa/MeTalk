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


class ChatUserListViewController:UIViewController, UINavigationControllerDelegate{
    ///インスタンス化(View)
    let ChatUserListTableView = GeneralTableView()
    ///RealMからデータを受け取るようの変数
    var itemList: Results<ListUsersInfoLocal>!
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
        ///ナビゲーションバーの設定
        ///barボタン初期設定
//        editItem = UIBarButtonItem(title: "編集", style: .plain, target: self, action: #selector(editItemButtonPressed(_:)))
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
        
        if self.ChatUserListTableView.contentOffset.y + self.ChatUserListTableView.frame.size.height > self.ChatUserListTableView.contentSize.height && scrollView.isDragging{
            loadDataLockFlg = false
            loadToLimitCount = loadToLimitCount + 15
//            self.talkListUsersDataGet(limitCount: loadToLimitCount)
            
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

        var userInfoData = self.talkListUsersMock[indexPath.row]
        
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
        
        
        ///プロファイルイメージをセルに反映
        if let profilaImage = userInfoData.profileImage {
            cell.talkListUserProfileImageView.image = profilaImage
        } else {

            ///取得したIDでユーザー情報の取得を開始(プロフィール画像)
            userInfo.contentOfFIRStorageGet(callback: { imageStruct in
                ///Nilでない場合はコールバック関数で返ってきたイメージ画像をオブジェクトにセット
                if imageStruct.image != nil {
                    cell.talkListUserProfileImageView.image = imageStruct.image
//                    self.talkListUsersMock[indexPath.row].profileImage = image
//                    self.chatUserListLocalImageRegist(Realm: realm, UID: userInfoData.UID, profileImage: imageStruct.image!, updataDate: imageStruct.updataDate!)
                    if let updateDate = imageStruct.updataDate{
                        self.chatUserListLocalImageRegist(Realm: realm, UID: userInfoData.UID, profileImage: imageStruct.image!, updataDate: updateDate)
                    } else {
                        self.chatUserListLocalImageRegist(Realm: realm, UID: userInfoData.UID, profileImage: imageStruct.image!, updataDate: Date())
                    }

                ///コールバック関数でNilが返ってきたら初期画像を設定
                } else {
                    print("mock:\(self.talkListUsersMock.count)_indexpath:\(indexPath.row)")
                    cell.talkListUserProfileImageView.image = UIImage(named: "InitIMage")
//                    self.talkListUsersMock[indexPath.row].profileImage = UIImage(named: "InitIMage")
                }
            }, UID: userInfoData.UID)
        }
        
        
        
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
                print(data.NewMessage)
                self.talkListUsersMock.append(talkListUserStruct(UID: data.UID, userNickName: data.userNickName, profileImage: nil,UpdateDate:data.upDateDate, NewMessage: data.NewMessage, listend: false, sendUID: data.sendUID))
            }
            
            ///ロードフラグをTrue
            self.loadDataLockFlg = true
            
            self.ChatUserListTableView.reloadData()
            
        }, UID: uid, argLatestTime: argLastetTime,limitCount: limitCount)
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
        userInfo.contentOfFIRStorageGet(callback: { imageStruct in
            ///ドキュメントにデータが入るまではセルを選択できないようにする
            self.ChatUserListTableView.allowsSelection = false
            ///Nilでない場合はコールバック関数で返ってきたイメージ画像をオブジェクトにセット
            if imageStruct.image != nil {
                self.selfProfileImageView.image = imageStruct.image
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
        ///ローカルDBにデータが入っている場合はデータをユーザー配列に投入する
        let realm = try! Realm()
        
        let localDBGetData = realm.objects(ListUsersInfoLocal.self)

        for data in localDBGetData {
            print(data.UID)
//            print(data.UID,data.userNickName,data.upDateDate,data.NewMessage,data.listend,data.sendUID)
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
                    self.ChatUserListTableView.reloadData()
                    triggerFlgCount = 1
                    return
                }

                self.talkListUsersMock.remove(at: indexNo)
                self.talkListUsersMock.insert(talkListUserStruct.init(UID: documentData.documentID, userNickName: nil, profileImage: nil, UpdateDate: UpdateDate, NewMessage: NewMessage, listend: listend, sendUID: sendUID), at: 0)
                self.ChatUserListTableView.reloadData()
                triggerFlgCount = 1
                
                
//                ///トーク対象者との最新のメーセージ情報を取得（※1とは別DB）
//                let talkRoomID = ChatDataManagedData().ChatRoomID(UID1: Auth.auth().currentUser!.uid, UID2: documentData.documentID)
//
//                self.databaseRef.child("Chat").child(talkRoomID).queryLimited(toLast: 1).queryOrdered(byChild: "Date").getData(completion: { error, snapshot in
//
//                    guard let error = error {
//                        print(err)
//                    }
//
//                    if let postDict = snapshot.value as? [String: Any] {
//
//                        let message = postDict["message"] as? String
//                        let senderID = postDict["sender"] as? String
//                        let date = postDict["Date"] as? String
//                        let messageID = postDict["messageID"] as? String
//                        let listend = postDict["listend"] as? Bool ?? false
//
//                        ///
//
//                    }
//                })

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
        guard let result = result?.upDateDate else {
            let calendar = Calendar(identifier: .gregorian)
            let date = Date()
            let modifiedDate = calendar.date(byAdding: .day, value: -10000, to: date)!
            
            return modifiedDate
                
//            ローカルデータを一件も取得できなかったときに（初期状態）に現在時刻を返しているために何も取ってこれなかった。
//            　　　　ここをすごい過去の時間にして全てのデータを取ってくるようにする。またここが完成したら画像データのmetadataが取得できているかを確認する。
        }
        return result
    }
    
    ///ローカルDBにイメージを保存
    func chatUserListLocalImageRegist(Realm:Realm,UID:String,profileImage:UIImage,updataDate:Date){
        let realm = Realm
        
        //UserDefaults のインスタンス生成
        let userDefaults = UserDefaults.standard
        
        // ドキュメントディレクトリの「ファイルURL」（URL型）定義
        var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        // ドキュメントディレクトリの「パス」（String型）定義
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        //②保存するためのパスを作成する
         func createLocalDataFile() {
             // 作成するテキストファイルの名前
             let fileName = "\(UID)_profileimage.png"

             // DocumentディレクトリのfileURLを取得
             if documentDirectoryFileURL != nil {
                 // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
                 let path = documentDirectoryFileURL.appendingPathComponent(fileName)
                 documentDirectoryFileURL = path
             }
         }

        //Realmのテーブルをインスタンス化
        let  listUsersImageLocal = ListUsersImageLocal()
        
        do{
            try listUsersImageLocal.profileImageURL = documentDirectoryFileURL.absoluteString
                listUsersImageLocal.updataDate = updataDate
        }catch{
            print("画像の保存に失敗しました")
        }
        try! realm.write{realm.add(listUsersImageLocal)}
        
        createLocalDataFile()
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
}
