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


class UserListViewController:UIViewController,UINavigationControllerDelegate{
    ///インスタンス化(View)
    let CHATUSERLISTTABLEVIEW = GeneralTableView()
    ///RealMからデータを受け取るようの変数
    var itemList: Results<ListUsersInfoLocal>!
    ///インスタンス化(Model)
    let UID = Auth.auth().currentUser?.uid
    let LOCALPROFILE:localProfileDataStruct
    let TALKDATAHOSTING:TalkDataHostingManager = TalkDataHostingManager()
    let CONTENTSHOSTING:ContentsDatahosting = ContentsDatahosting()
    ///インスタンス化(Controller)
    let SHOWIMAGEVIEWCONTROLLER = ShowImageViewController()
    ///RealMオブジェクトをインスタンス化
    let REALM = try! Realm()
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
    var UserListMock:[profileInfoLocal] = []
    
    init () {
        self.LOCALPROFILE = localProfileDataStruct(UID:UID!)
        super.init()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///ビューが表示されるたびに実行する処理群
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///トークリストユーザー一覧取得
        talkListUsersDataGet(limitCount: 15)
        ///テーブルビューを適用
        self.view = CHATUSERLISTTABLEVIEW
        self.view.backgroundColor = .black
        ///テーブルビューのデリゲート処理
        CHATUSERLISTTABLEVIEW.dataSource = self
        CHATUSERLISTTABLEVIEW.delegate = self
        ///セルの登録
        CHATUSERLISTTABLEVIEW.register(UserListTableViewCell.self, forCellReuseIdentifier: "UserListTableViewCell")
        
        ///タイトルラベル追加
        navigationItem.title = "ユーザーリスト"
        ///自身の情報をローカルから取得

        LOCALPROFILE.userProfileDatalocalGet { localData, err in
            guard let err = err else  {
                return
            }
            self.meInfoData = localData
        }
    }
}

///↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
///↓↓↓◆◆◆TABLEVIRE◆◆◆↓↓↓
///↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

extension UserListViewController:UITableViewDelegate, UITableViewDataSource{
    ///スクロール中の処理
    /// - Parameters:None
    /// - Returns: None
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ///取得しているユーザーリストの数が15件未満の場合またはデータのロードフラグがTrueは何もしない
        if !loadDataLockFlg || UserListMock.count < 15 {
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
        return UserListMock.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListTableViewCell", for: indexPath ) as! UserListTableViewCell
        ///Mockのインデックス番号の中身を取得
        let USERINFODATA = self.UserListMock[indexPath.row]
                
        ///セルのユーザー情報構造体にユーザー情報を投入
        cell.celluserStruct = USERINFODATA
        
        ///画像に関してはCell生成の一番最初は問答無用でInitイメージを適用
        cell.talkListUserProfileImageView.image = UIImage(named: "InitIMage")

        ///ユーザーネーム設定処理
        if let nickname = USERINFODATA.lcl_NickName {
            ///セルのUIDと一致したらセット
            if cell.celluserStruct!.lcl_UID == USERINFODATA.lcl_UID {
                cell.nickNameSetCell(Item: nickname)
            }
        } else {
            ///入っていない場合は未設定
            cell.nickNameSetCell(Item: "退会したユーザー")
        }
        
        //最新メッセージをセルに反映する処理
        let ABOUTMESSAGE = USERINFODATA.lcl_AboutMeMassage
        cell.aboutMessageSetCell(Item: ABOUTMESSAGE!)
        ///自身の相手に押したライクボタン押下時間を取得して表示する処理（ローカルDB）
        LOCALPROFILE.userProfileDatalocalGet { localData, err in
            guard let err = err else {
                print("この機能を使用する前に自身のデータを再設定してください。")
                return
            }
            if let PUSHEDDATE = localData.lcl_LikeButtonPushedDate{
                cell.celluserStruct?.lcl_LikeButtonPushedFLAG = true
                let DIFFTIME = self.pushTimeDiffDate(pushTime: PUSHEDDATE)
                ///差分が60分未満（IMAGE変更）
                if DIFFTIME < 60.0 {
                    cell.ImageView.image = UIImage(named: "LIKEBUTTON_IMAGE_Pushed")
                }
            }
        }

        let TOOL = TIME()
        ///サーバーに対して画像取得要求
        CONTENTSHOSTING.ImageDataGetter(callback: { Image, err in
            if Image.lcl_ProfileImage != nil,cell.celluserStruct!.lcl_UID == USERINFODATA.lcl_UID!{
                guard let err = err else {
                    cell.talkListUserProfileImageView.image = UIImage(named: "InitIMage")
                    return
                }
                cell.talkListUserProfileImageView.image = Image.lcl_ProfileImage 
            }
        }, UID: USERINFODATA.lcl_UID!, UpdateTime: TOOL.pastTimeGet())

        ///セルのデリゲート処理
        cell.delegate = self
        
        return cell
    }
    ///テーブルビューの各セルがタップされた時の処理設定
    /// - Parameters:None
    /// - Returns: None
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ///セル情報を取得
        let cell = tableView.cellForRow(at: indexPath) as! UserListTableViewCell
        ///選んだセルの相手のUIDを取得
        let YouUID = self.UserListMock[indexPath.row].lcl_UID
    }
    
    ///横にスワイプした際の処理
    /// - Parameters:None
    /// - Returns: None
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        ///ブロックボタンの生成
        let editAction = UIContextualAction(style: .normal, title: "ブロック") { (action, view, completionHandler) in
            ///セル情報を取得
            let cell = tableView.cellForRow(at: indexPath) as! UserListTableViewCell
            ///ローカルDBから対象のユーザーデータを取得
            let realm = try! Realm()
            let localDBGetData = realm.objects(ListUsersInfoLocal.self)
            guard let cellUID = cell.celluserStruct?.lcl_UID else {
                print("セルのUID情報を取得できませんでした")
                return
            }
            
            let PREDICATE = NSPredicate(format: "lcl_UID == %@", cellUID)
            let userStruct = localDBGetData.filter(PREDICATE).first

            if let userStruct = userStruct{
                    self.blockPushed(profileData: userStruct, targetUID: cellUID)
                    // 実行結果に関わらず記述
                    completionHandler(true)
                    return
            } else {
               preconditionFailure("ローカルに保存されていないデータの処理を行なっています。")
                // 実行結果に関わらず記述
                completionHandler(true)
            }
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

extension UserListViewController {
    ///トークリストのユーザー一覧を取得
    /// - Parameters:
    ///- UID: 取得するトークリスト対象のユーザーUID
    ///- argLatestTime:ローカルに保存してある最終更新日
    ///- limitCount: 取得する件数
    /// - Returns:
    /// -UserUIDUserListMock:取得したユーザーリスト情報
    func talkListUsersDataGet(limitCount:Int) {
        TALKDATAHOSTING.newTalkUserListGetter(callback: { UserList, err in
            if err != nil {
                let action = actionSheets(dicidedOrOkOnlyTitle: "ユーザー取得時に問題が発生いたしました。", message: "もう一度試してください", buttonMessage: "OK")
                action.okOnlyAction(callback: { result in
                    return
                }, SelfViewController: self)
                return
            }
            
            ///もしも現在のトークユーザーリストのカウントとDBから取得してきたトークユーザーリストのカウントが等しければロードストップのフラグにTrue
            if UserList.count == self.UserListMock.count {
                self.loadDataStopFlg = true
            }
            ///トークリスト配列を一個ずつ回す
            for data in UserList {
                ///サーバーから取得したユーザーのUIDがあったらそのIndexNoを取得
                let indexNo = self.UserListMock.firstIndex(where: { $0.lcl_UID == data.lcl_UID })
                ///配列にある古いデータを削除
                if let indexNo = indexNo{
                    self.UserListMock.remove(at: indexNo)
                }
                ///サーバーから取得したデータを配列に入れ直す
                self.UserListMock.append(data)
            }
            ///ロードフラグをTrue
            self.loadDataLockFlg = true
            ///テーブルビューリロード処理
            self.CHATUSERLISTTABLEVIEW.reloadData()
        }, getterCount: limitCount)
//
//
//        USERDATAMANAGE.userListInfoDataGet(callback: { USERSLISTMOCK in
//            ///もしも現在のトークユーザーリストのカウントとDBから取得してきたトークユーザーリストのカウントが等しければロードストップのフラグにTrue
//            if USERSLISTMOCK.count == self.UserListMock.count {
//                self.loadDataStopFlg = true
//            }
//            ///トークリスト配列を一個ずつ回す
//            for data in USERSLISTMOCK {
//                ///サーバーから取得したユーザーのUIDがあったらそのIndexNoを取得
//                let indexNo = self.UserListMock.firstIndex(where: { $0.UID == data.UID })
//                ///配列にある古いデータを削除
//                if let indexNo = indexNo{
//                    self.UserListMock.remove(at: indexNo)
//                }
//                ///サーバーから取得したデータを配列に入れ直す
//                self.UserListMock.append(UserListStruct(UID: data.UID, userNickName: data.userNickName, aboutMessage: data.aboutMessage, Age: data.Age, From: data.From!, Sex: data.Sex,createdAt: data.createdAt,updatedAt: data.updatedAt))
//            }
//            ///ロードフラグをTrue
//            self.loadDataLockFlg = true
//            ///テーブルビューリロード処理
//            self.CHATUSERLISTTABLEVIEW.reloadData()
//
//
//        }, CountLimit: limitCount)
    }
}
///ライクボタン処理
extension UserListViewController:UserListTableViewCellDelegate{

    
    ///ライクボタン押下時のアクション
    /// - Parameters:
    ///- CELL: CELL全体が引数
    ///- CELLUSERSTRUCT:サーバーから取得した個人データ（ReloadViewしてセル更新されるまで最新にはならない）
    func likebuttonPushed(CELL: UserListTableViewCell, CELLUSERSTRUCT: profileInfoLocal) {
                
        if CELLUSERSTRUCT.lcl_UID  == "unknown" {
            print("ここにきたらエラーアラート")
        }
        
        if !CELL.celluserStruct!.lcl_LikeButtonPushedFLAG {
            ///画像タップ時のイメージ保存
            CELL.ImageView.image = UIImage(named: "LIKEBUTTON_IMAGE_Pushed")
            ///ローカルとサーバーそれぞれにライクボタンデータ送信
            self.LikeButtonPushedInfoUpdate(CELLUSERSTRUCT: CELLUSERSTRUCT)
            ///ReloadView前の連続押下防止
            CELL.celluserStruct?.lcl_LikeButtonPushedFLAG = true
        } else {
            ///ローカルデータから情報取得
            LOCALPROFILE.userProfileDatalocalGet { localdata, err in
                guard let err = err else {
                    print("この機能を使用する前に自身のデータを更新してください。")
                    return
                }
                ///ローカルより相手にPushした時間を取得
                if let PUSHEDLOCALDATA = localdata.lcl_LikeButtonPushedDate {
                    ///現在時間との差分を求める
                    let DIFFTIME = self.pushTimeDiffDate(pushTime: PUSHEDLOCALDATA)
                    ///差分が60分未満（拒否）
                    if DIFFTIME < 60.0 {
                        let INTTIME = Int(DIFFTIME)
                        let minuteString = String(60 - INTTIME)
                        ///時間表示ラベル調整
                        CELL.UItextLabel.textAlignment = NSTextAlignment.center
                        CELL.UItextLabel.text = "\(minuteString)分"
                        CELL.UItextLabel.font = CELL.UItextLabel.font.withSize(CELL.UItextLabel.bounds.width * 0.25)
                        ///ボタンを押下した際の文字表示処理
                        ///TIMER処理(下の関数呼び出し)
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.0, repeats: false) { (timer) in
                            self.animateView(CELL.UITextView)
                        }
                    ///差分が60分以上(許可)
                    } else {
                        ///画像タップ時のイメージ保存
                        CELL.ImageView.image = UIImage(named: "LIKEBUTTON_IMAGE_Pushed")
                        ///ローカルとサーバーそれぞれにライクボタンデータ送信
                        self.LikeButtonPushedInfoUpdate(CELLUSERSTRUCT: CELLUSERSTRUCT)
                    }
                ///ローカルに時間が入っていない時（多分入らない）
                } else {
                    ///画像タップ時のイメージ保存
                    CELL.ImageView.image = UIImage(named: "LIKEBUTTON_IMAGE_Pushed")
                    ///ローカルとサーバーそれぞれにライクボタンデータ送信
                    self.LikeButtonPushedInfoUpdate(CELLUSERSTRUCT: CELLUSERSTRUCT)
                }
            }
        }
    }
    
    func animateView(_ viewAnimate: UIView) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
            viewAnimate.alpha = 1
        } completion: { (_) in
            UIView.animate(withDuration: 0.5, delay: 1, options: .curveEaseIn) {
                viewAnimate.alpha = 0
            }
        }
    }
    
    func pushTimeDiffDate(pushTime:Date) -> Double {
        
        print("Date:\(Date())PushedDate:\(pushTime)")
        
        let minute = round(Date().timeIntervalSince(pushTime)/60)
        
        return minute
    }
    
    func LikeButtonPushedInfoUpdate(CELLUSERSTRUCT:profileInfoLocal) {
        let ROOMID = chatTools()
        ///ライクボタン情報をトークDBに送信
        let roomID = ROOMID.roomIDCreate(UID1: UID!, UID2: CELLUSERSTRUCT.lcl_UID!)
        ///自身の情報からニックネームを取得
        let nickname = self.meInfoData!.lcl_NickName
        let likeMessage = messageLocal()
        likeMessage.lcl_RoomID = roomID
        likeMessage.lcl_MessageID = UUID().uuidString
        likeMessage.lcl_Listend = true
        likeMessage.lcl_Date = Date()
        likeMessage.lcl_Sender = UID!
        likeMessage.lcl_LikeButtonFLAG = true
        likeMessage.lcl_Message = "💓"
        let LOCALTALK:localTalkDataStruct = localTalkDataStruct(roomID: likeMessage.lcl_RoomID,updateobject: likeMessage)

        ///ライクデータのインクリメントを相手のデータに加算
        TALKDATAHOSTING.LikeDataPushIncrement(TargetUID: CELLUSERSTRUCT.lcl_UID!)
        ///それぞれのトーク情報にライクボタン情報を送信
        TALKDATAHOSTING.talkListUserAuthUIDCreate(UID1: UID!, UID2: CELLUSERSTRUCT.lcl_UID!, message: "💓", sender: UID!, nickName1: nickname ?? "Unknown", nickName2: CELLUSERSTRUCT.lcl_NickName!, like: true, blocked: false)
//        ///それぞれのトーク情報にライクボタン情報を送信
//        let chatManageData = ChatDataManagedData()
//        chatManageData.talkListUserAuthUIDCreate(UID1: UID!, UID2: CELLUSERSTRUCT.UID, NewMessage: "💓", meNickName: nickname ?? "Unknown", youNickname: CELLUSERSTRUCT.userNickName!, LikeButtonFLAG: true, blockedFlag: nil)
        

        TALKDATAHOSTING.likePushing(message: "💓", messageId: UUID().uuidString, sender: UID!, Date: Date(), roomID: roomID)
        ///ローカルデータにライクボタン情報を保存
        LOCALTALK.localMessageDataRegist()
        
//        LikeUserDataRegist_Update(UID: CELLUSERSTRUCT.UID, nickname: CELLUSERSTRUCT.userNickName, sex: CELLUSERSTRUCT.Sex, aboutMassage: CELLUSERSTRUCT.aboutMessage, age: CELLUSERSTRUCT.Age, area: CELLUSERSTRUCT.From, createdAt: CELLUSERSTRUCT.createdAt,updatedAt: CELLUSERSTRUCT.updatedAt, LikeButtonPushedFLAG:1, LikeButtonPushedDate: Date(),ViewController: self)
    }
}

extension UserListViewController {
    ///_プロフィール画像タップ時アクションシート_
    func profileImageButtonPushed(CELL: UserListTableViewCell, CELLUSERSTRUCT: profileInfoLocal) {
        ///アクションシートを表示してユーザーが選択した内容によって動作を切り替え
        let action = actionSheets(twoAtcionTitle1: "画像を表示", twoAtcionTitle2: "プロフィールを表示")
        
        action.showTwoActionSheets(callback: { result in
            switch result {
                ///画像を表示
            case .one:
                self.SHOWIMAGEVIEWCONTROLLER.profileImage = CELL.talkListUserProfileImageView.image
                self.present(self.SHOWIMAGEVIEWCONTROLLER, animated: true, completion: nil)
                ///画像を変更
            case .two:
                ///プロフィール画面遷移
                let TARGETPROFILEVIEWCONTROLLER = TargetProfileViewController(profileData: CELLUSERSTRUCT, profileImage: CELL.talkListUserProfileImageView.image ?? UIImage(named: "InitIMage")!)
                ///遷移先のControllerに対してプロフィール画像データを渡す
                self.navigationController?.pushViewController(TARGETPROFILEVIEWCONTROLLER, animated: true)
            }
        }, SelfViewController: self)
    }
    
    ///_セルタップ時アクションシート_
    ///アクションシートを表示してユーザーが選択した内容によって動作を切り替え
    func cellPushed(CELL: UserListTableViewCell, CELLUSERSTRUCT: UserListStruct) {
        ///アクションシートを表示してユーザーが選択した内容によって動作を切り替え
        let action = actionSheets(twoAtcionTitle1: "プロフィールを表示", twoAtcionTitle2: "トークを表示")
        
        action.showTwoActionSheets(callback: { result in
            switch result {
                ///画像を表示
            case .one:
                ///プロファイル用データ構造体作成
                let targetProfileObject = profileInfoLocal()
                targetProfileObject.lcl_NickName = CELLUSERSTRUCT.userNickName
                targetProfileObject.lcl_AboutMeMassage = CELLUSERSTRUCT.aboutMessage
                targetProfileObject.lcl_Sex = CELLUSERSTRUCT.Sex
                targetProfileObject.lcl_Age = CELLUSERSTRUCT.Age
                targetProfileObject.lcl_Area = CELLUSERSTRUCT.From
                targetProfileObject.lcl_DateCreatedAt = CELLUSERSTRUCT.createdAt
                targetProfileObject.lcl_DateUpdatedAt = CELLUSERSTRUCT.updatedAt
                targetProfileObject.lcl_UID = CELLUSERSTRUCT.UID
                targetProfileObject.lcl_LikeButtonPushedDate = CELLUSERSTRUCT.LikeButtonPushedDate
                targetProfileObject.lcl_LikeButtonPushedFLAG = CELLUSERSTRUCT.LikeButtonPushedFLAG

                ///プロフィール画面遷移
                let TARGETPROFILEVIEWCONTROLLER = TargetProfileViewController(profileData: targetProfileObject, profileImage: CELL.talkListUserProfileImageView.image ?? UIImage(named: "InitIMage")!)
                ///遷移先のControllerに対してプロフィール画像データを渡す
                TARGETPROFILEVIEWCONTROLLER.profileData
                self.navigationController?.pushViewController(TARGETPROFILEVIEWCONTROLLER, animated: true)
                ///トーク画面遷移
            case .two:
                break
            }
        }, SelfViewController: self)
    }
    
    ///_スライドボタンアクションシート_
    ///アクションシートを表示してユーザーが選択した内容によって動作を切り替え
    func blockPushed(profileData:ListUsersInfoLocal,targetUID:String) {
        let LOCALDATAMANAGER = localListUsersDataStruct()
        ///すでにブロックしている場合
        if profileData.lcl_BlockerFLAG {
            let alert = actionSheets(dicidedOrOkOnlyTitle: "このユーザーは既にブロックされています。ブロックを解除しますか？", message: "解除した場合、相手はメッセージの送信が行えるようになります。", buttonMessage: "確定")
            
            alert.okOnlyAction(callback: { result in
                switch result {
                case .one:
                    self.TALKDATAHOSTING.blockHosting(meUID: profileData.lcl_UID!, targetUID: targetUID, blocker: false)
                    LOCALDATAMANAGER.chatUserListInfoLocalDataRegist(USERLISTLOCALOBJECT: profileData)
                }
            }, SelfViewController: self)
            
        } else {
            ///ブロックされていない場合
            let alert = actionSheets(dicidedOrOkOnlyTitle: "このユーザーをブロックしますか？（ブロック反映まで時間がかかる場合があります。）", message: "ブロックした場合、メッセージの送信ができない他、ユーザー一覧に表示されません", buttonMessage: "確定")
            
            alert.okOnlyAction(callback: { result in
                switch result {
                case .one:
                    self.TALKDATAHOSTING.blockHosting(meUID: profileData.lcl_UID!, targetUID: targetUID, blocker: true)
                    LOCALDATAMANAGER.chatUserListInfoLocalDataRegist(USERLISTLOCALOBJECT: profileData)
                }
            }, SelfViewController: self)
        }
    }
    
    func userArrayCreate(userListStruct:UserListStruct,profileImagedata:UIImage) -> [String:Any]{
        
        var userInfoData:[String:Any] = [:]
        userInfoData["createdAt"] = userListStruct.createdAt
        userInfoData["Sex"] = userListStruct.Sex
        userInfoData["aboutMeMassage"] = userListStruct.aboutMessage
        userInfoData["nickname"] = userListStruct.userNickName
        userInfoData["age"] = userListStruct.Age
        userInfoData["area"] = userListStruct.From
        userInfoData["profileImageData"] = profileImagedata
        
        return userInfoData
        
    }
}
