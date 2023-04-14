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
import CoreAudio


class ChatUserListViewController:UIViewController, UINavigationControllerDelegate{
    ///インスタンス化(View)
    let CHATUSERLISTTABLEVIEW = GeneralTableView()
    ///インスタンス化(Model)
    let PLOFILEHOSTING = profileHosting()
    let UID = Auth.auth().currentUser?.uid
    let TALKLOCAL = localTalkDataStruct()
    let TALKHOSTING = TalkDataHostingManager()
    let CONTENTSHOSTING = ContentsDatahosting()
    let LOCALCONTENTSSTRUCT = localProfileContentsDataStruct()
    let LOCALLISTUSERS = localListUsersDataStruct()
    ///ローカルデータ取得
    let LOCALDATA = localProfileDataStruct(UID: Auth.auth().currentUser!.uid)
    ///自身の画像View
    var selfProfileImageView = UIImageView()
    ///自身のユーザー情報格納変数
    var meInfoData:profileInfoLocal?
    ///追加でロードする際のCount変数
    var loadToLimitCount:Int = 15
    ///重複してメッセージデータを取得しないためのフラグ
    var loadDataLockFlg:Bool = true
    ///追加メッセージデータ関数の起動を停止するフラグ
    var loadDataStopFlg:Bool = false
    ///バックボタンで戻ってきた時に格納してあるUID
    var backButtonUID:String?
    ///トークリストユーザー情報格納配列
    var talkListUsersMock:[ListUsersInfoLocal] = []
    
    ///ビューが表示されるたびに実行する処理群
    override func viewWillAppear(_ animated: Bool) {
        ///自身の情報を取得
        userInfoDataGet()
    }
    
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
        cell.cellUID = USERINFODATA.lcl_UID

        ///ローカル保存処理
        LOCALLISTUSERS.chatUserListInfoLocalDataRegist(USERLISTLOCALOBJECT: USERINFODATA)

        ///ユーザーネーム設定処理
        if let nickname = USERINFODATA.lcl_UserNickName {
            ///セルのUIDと一致したらセット
            if cell.cellUID == USERINFODATA.lcl_UID {
                cell.nickNameSetCell(Item: nickname)
            }
        }
        
        //最新メッセージをセルに反映する処理
        let newMessage = USERINFODATA.lcl_NewMessage
        cell.newMessageSetCell(Item: newMessage!)
        ///ローカルDBインスタンス化
        let targetImage = LOCALCONTENTSSTRUCT.chatUserListLocalImageInfoGet(UID: USERINFODATA.lcl_UID!)
        ///プロファイルイメージをセルに反映(ローカルDB)
        cell.talkListUserProfileImageView.image = targetImage.profileImage

        ///サーバーに対して画像取得要求
        CONTENTSHOSTING.ImageDataGetter(callback: { data, err in
            if data.lcl_UID! == "Yd7MNepBxzSc0p7bpp3LjcwSl1h2" {
                print("画像は存在しているはずです。")
            }
            if cell.cellUID == USERINFODATA.lcl_UID {
                ///エラー時ローカルデータ更新
                if err != nil {
                    cell.talkListUserProfileImageView.image = targetImage.profileImage
                    self.LOCALCONTENTSSTRUCT.chatUserListLocalImageRegist(UID: USERINFODATA.lcl_UID!, profileImage: targetImage.profileImage, updataDate: targetImage.lcl_UpdataDate!)
                }
                
                cell.talkListUserProfileImageView.image = data.profileImage
                self.LOCALCONTENTSSTRUCT.chatUserListLocalImageRegist(UID: USERINFODATA.lcl_UID!, profileImage: data.profileImage, updataDate: data.lcl_UpdataDate!)
            }
        }, UID: USERINFODATA.lcl_UID!, UpdateTime: targetImage.lcl_UpdataDate!)
        
         
        ///もしもセルの再利用によってベルアイコンが存在してしまっていたら初期化
        if cell.nortificationImage.image != nil {
            cell.nortificationImage.image = nil
        }
        ///listendがTrue且つ送信者IDが自分でない場合はベルアイコンを表示()
        if USERINFODATA.lcl_Listend && USERINFODATA.lcl_SendUID != UID {
            cell.nortificationImageSetting()
        }
        ///バックボタンで戻ってきた際のUIDがCellのUIDと合致していたらベルアイコンは非表示
        if let backButtonUID = backButtonUID {
            if backButtonUID == USERINFODATA.lcl_UID {
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
        let YouUID = self.talkListUsersMock[indexPath.row].lcl_UID
        
        guard let CELLUID = cell.cellUID  else {
            let alert = actionSheets(dicidedOrOkOnlyTitle: "ユーザーに異常が発生しました", message: "このユーザーとトークすることはできません。", buttonMessage:  "OK")
            alert .okOnlyAction(callback: { result in
                switch result {
                case .one:
                    return
                }
            }, SelfViewController: self)
            return
        }
        
        ///ローカルDBの処理で行っていないのは相手のトーク情報をタップした時点で取得したいため
        TALKHOSTING.talkListTargetUserDataGet(callback: { ListUsersInfo, err in
            let TARGETPROFILEINFOLOCAL:profileInfoLocal = profileInfoLocal()
            TARGETPROFILEINFOLOCAL.lcl_NickName = ListUsersInfo.lcl_UserNickName
            ///遷移先のチャット画面のViewcontrollerをインスタンス化
            let CHATVIEWCONTROLLER = ChatViewController(Youinfo: TARGETPROFILEINFOLOCAL, Meinfo: self.meInfoData!)
            ///UIDから生成したルームIDを値渡しする
            let TOOLS = chatTools()
            let roomID = TOOLS.roomIDCreate(UID1: Auth.auth().currentUser!.uid, UID2: YouUID!)
            CHATVIEWCONTROLLER.roomID = roomID
            ///それぞれのユーザー情報を渡す
            CHATVIEWCONTROLLER.MeInfo = self.meInfoData!
            CHATVIEWCONTROLLER.MeUID = self.UID
            CHATVIEWCONTROLLER.YouUID = YouUID!
            CHATVIEWCONTROLLER.meProfileImage = self.selfProfileImageView.image
            CHATVIEWCONTROLLER.youProfileImage = cell.talkListUserProfileImageView.image
            ///新着ベルアイコンを非表示にする＆該当ユーザーのlisntendをFalseに設定
            cell.nortificationImageRemove()
            ListUsersInfo.lcl_Listend = false
            ///ローカルDB更新/新規
            self.LOCALLISTUSERS.chatUserListInfoLocalDataRegist(USERLISTLOCALOBJECT: ListUsersInfo)
            
           ///ブロックされている場合
            if ListUsersInfo.lcl_BlockedFLAG {
                CHATVIEWCONTROLLER.blocked = true
            }
            ///ブロックしている場合
            if ListUsersInfo.lcl_BlockerFLAG {
                CHATVIEWCONTROLLER.blocker = true
            }
            ///UINavigationControllerとして遷移
            self.navigationController?.pushViewController(CHATVIEWCONTROLLER, animated: true)
        }, UID1: UID!, UID2: CELLUID)
        
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
//    func talkListUsersDataGet(limitCount:Int,argLastetTime:Date) {
//
//        USERDATAMANAGE.talkListUsersDataGet(callback: { UserUIDUserListMock in
//            ///もしも現在のトークユーザーリストのカウントとDBから取得してきたトークユーザーリストのカウントが等しければロードストップのフラグにTrue
//            if UserUIDUserListMock.count == self.talkListUsersMock.count {
//                self.loadDataStopFlg = true
//            }
//            ///トークリスト配列を一個ずつ回す
//            for data in UserUIDUserListMock {
//
//                ///サーバーから取得したユーザーのUIDがあったらそのIndexNoを取得
//                let indexNo = self.talkListUsersMock.firstIndex(where: { $0.UID == data.UID })
//                ///配列にある古いデータを削除
//                if let indexNo = indexNo{
//                    self.talkListUsersMock.remove(at: indexNo)
//                }
//                ///サーバーから取得したデータを配列に入れ直す
//                self.talkListUsersMock.append(TalkListUserStruct(UID: data.UID, userNickName: data.userNickName, profileImage: nil,UpdateDate:data.upDateDate, NewMessage: data.NewMessage, listend: false, sendUID: data.sendUID))
//            }
//            ///ロードフラグをTrue
//            self.loadDataLockFlg = true
//            ///テーブルビューリロード処理
//            self.CHATUSERLISTTABLEVIEW.reloadData()
//        }, UID: UID, argLatestTime: argLastetTime,limitCount: limitCount)
//    }
    ///自身の情報を取得
    func userInfoDataGet(){
        var dataReflect_CellSelecter = {(document:profileInfoLocal) in
            ////ドキュメントにデータが入るまではセルを選択できないようにする
            self.CHATUSERLISTTABLEVIEW.allowsSelection = false
            ///データ投入
            self.meInfoData = document
            ///セル選択を可能にする
            self.CHATUSERLISTTABLEVIEW.allowsSelection = true
        }
        
        LOCALDATA.userProfileDatalocalGet(callback: { document,err  in
            if err != nil {
                hostingUserInfoGetter()
                return
            }
            dataReflect_CellSelecter(document)
        })
        
        func hostingUserInfoGetter() {
            let hosting = profileHosting()
            hosting.FireStoreProfileDataGetter(callback: { localdata, err in
                if err != nil {
                    let action = actionSheets(dicidedOrOkOnlyTitle: "データが破損しております。", message: "デフォルトの値を適用します", buttonMessage: "OK")
                    action.dicidedAction(callback: { nill in
                        self.meInfoData = localdata
                    }, SelfViewController: self)
                    return
                }
                dataReflect_CellSelecter(localdata)
            }, UID: UID!)
        }
    }
    ///自分の画像を取得してくる()
    func contentOfFIRStorageGet() {
        let TOOL = TIME()
        
        ///サーバーに対して画像取得要求
        CONTENTSHOSTING.ImageDataGetter(callback: { Img, ERR in
            ///ドキュメントにデータが入るまではセルを選択できないようにする
            self.CHATUSERLISTTABLEVIEW.allowsSelection = false
            ///画像セット
            self.selfProfileImageView.image = Img.profileImage
            ///セル選択を可能にする
            self.CHATUSERLISTTABLEVIEW.allowsSelection = true
        }, UID: UID!, UpdateTime: TOOL.pastTimeGet())
    }
    
    ///トークリストのリアルタイムリスナー
    func talkListListner() {
        ///ローカルDBにデータが入っている場合はデータをユーザー配列に投入する
        let localDBGetData = TALKLOCAL.localTalkListDataGet()
        
        for data in localDBGetData {
            if let UID = data.lcl_UID,let userNickname = data.lcl_UserNickName,let sendUID = data.lcl_SendUID{
                self.talkListUsersMock.append(data)
            }
        }
        ///トークリスト配列内で並び替え
        let pastTime = TIME()

        self.talkListUsersMock = self.talkListUsersMock.sorted(by: {$0.lcl_UpdateDate ?? pastTime.pastTimeGet() > $1.lcl_UpdateDate ?? pastTime.pastTimeGet()})
        var triggerFlgCount:Int = 0
    
        ///リスナー用FireStore変数
        let db = Firestore.firestore()
        guard let uid = UID else {
            return
        }
        ///リスナー処理開始
        db.collection("users").document(uid).collection("TalkUsersList").order(by: "UpdateAt",descending: true).limit(to: 1).addSnapshotListener { (document,err) in
            let TALKLISTUSERS:ListUsersInfoLocal = ListUsersInfoLocal()
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
                let indexNo = self.talkListUsersMock.firstIndex(where: {$0.lcl_UID == documentData.documentID})

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

                ///相手のニックネーム
                guard let youNickname = documentData["youNickname"] as? String else {
                    print("送信者UID情報が取得できませんでした")
                    return
                }
                
                ///トークリスト配列に存在している
                if let indexNo = indexNo {

                    ///ブロック変換
                    if let blocked = documentData["blocked"] as? Bool {
                            ///存在していたら並び替えは変えずに基の情報にブロック情報を追加
                        self.talkListUsersMock[indexNo].lcl_BlockedFLAG = blocked
                            self.CHATUSERLISTTABLEVIEW.reloadData()
                            return
                    }
                }
                TALKLISTUSERS.lcl_UID = documentData.documentID
                TALKLISTUSERS.lcl_UserNickName = youNickname
                TALKLISTUSERS.lcl_UpdateDate = UpdateDate
                TALKLISTUSERS.lcl_NewMessage = NewMessage
                TALKLISTUSERS.lcl_Listend = listend
                TALKLISTUSERS.lcl_SendUID = sendUID
                    
                ///リスナーで取得された情報がトークリスト配列になかった場合は
                ///新規で配列に投入
                guard let indexNo = indexNo else {
                    self.talkListUsersMock.insert(TALKLISTUSERS, at: 0)
                    self.CHATUSERLISTTABLEVIEW.reloadData()
                    triggerFlgCount = 1
                    return
                }
                ///更新データなので一旦リムーブして最新データを配列に投入
                self.talkListUsersMock.remove(at: indexNo)
                self.talkListUsersMock.insert(TALKLISTUSERS, at: 0)
                self.CHATUSERLISTTABLEVIEW.reloadData()
                triggerFlgCount = 1
            }
        }
    }
}
