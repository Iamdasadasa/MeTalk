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


class UserListViewController:UIViewController, UINavigationControllerDelegate{
    ///インスタンス化(View)
    let CHATUSERLISTTABLEVIEW = GeneralTableView()
    ///RealMからデータを受け取るようの変数
    var itemList: Results<ListUsersInfoLocal>!
    ///インスタンス化(Model)
    let USERDATAMANAGE = UserDataManage()
    let UID = Auth.auth().currentUser?.uid
    ///RealMオブジェクトをインスタンス化
    let REALM = try! Realm()
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
    var UserListMock:[UserListStruct] = []
    
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
        print(USERINFODATA.UID)
        ///セルUID変数に対してUIDを代入
        cell.cellUID = USERINFODATA.UID
        
        ///画像に関してはCell生成の一番最初は問答無用でInitイメージを適用
        cell.talkListUserProfileImageView.image = UIImage(named: "InitIMage")

        ///ユーザーネーム設定処理
        if let nickname = USERINFODATA.userNickName {
            ///セルのUIDと一致したらセット
            if cell.cellUID == USERINFODATA.UID {
                cell.nickNameSetCell(Item: nickname)
            }
        } else {
            ///入っていない場合は未設定
            cell.nickNameSetCell(Item: "退会したユーザー")
        }
        
        //最新メッセージをセルに反映する処理
        let ABOUTMESSAGE = USERINFODATA.aboutMessage
        cell.aboutMessageSetCell(Item: ABOUTMESSAGE)

        ///サーバーに対して画像取得要求
        USERDATAMANAGE.contentOfFIRStorageGet(callback: { imageStruct in
            ///取得してきた画像がNilでない且つセルに設定してあるUIDとサーバー取得UIDが合致した場合
            ///イメージ画像をオブジェクトにセット
            if imageStruct.image != nil,cell.cellUID == USERINFODATA.UID{
                cell.talkListUserProfileImageView.image = imageStruct.image ?? UIImage(named: "InitIMage")
            }
        }, UID: USERINFODATA.UID, UpdateTime: ChatDataManagedData.pastTimeGet())
         
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
        let YouUID = self.UserListMock[indexPath.row].UID
            ///遷移先のプロフィール画面のViewcontrollerをインスタンス化
//            let CHATVIEWCONTROLLER = ChatViewController()
            ///それぞれのユーザー情報を渡す
//            CHATVIEWCONTROLLER.MeInfo = self.meInfoData
//            CHATVIEWCONTROLLER.MeUID = self.UID
//            CHATVIEWCONTROLLER.YouInfo = document
//            CHATVIEWCONTROLLER.YouUID = YouUID
//            CHATVIEWCONTROLLER.meProfileImage = self.selfProfileImageView.image
//            CHATVIEWCONTROLLER.youProfileImage = cell.talkListUserProfileImageView.image
            ///新着ベルアイコンを非表示にする＆該当ユーザーのlisntendをFalseに設定
//            cell.nortificationImageRemove()
//            self.UserListMock[indexPath.row].listend = false
//            ///ローカルDBにニックネームの最新情報のみ更新
//            chatUserListInfoLocalExstraRegist(Realm: self.REALM, UID: YouUID, usernickname: document!["nickname"] as? String, newMessage: nil, updateDate: nil, listend: nil, SendUID: nil)
            ///UINavigationControllerとして遷移
//            self.navigationController?.pushViewController(CHATVIEWCONTROLLER, animated: true)
//        }, UID: YouUID)
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

extension UserListViewController {
    ///トークリストのユーザー一覧を取得
    /// - Parameters:
    ///- UID: 取得するトークリスト対象のユーザーUID
    ///- argLatestTime:ローカルに保存してある最終更新日
    ///- limitCount: 取得する件数
    /// - Returns:
    /// -UserUIDUserListMock:取得したユーザーリスト情報
    func talkListUsersDataGet(limitCount:Int) {
        
        USERDATAMANAGE.userListInfoDataGet(callback: { USERSLISTMOCK in
            ///もしも現在のトークユーザーリストのカウントとDBから取得してきたトークユーザーリストのカウントが等しければロードストップのフラグにTrue
            if USERSLISTMOCK.count == self.UserListMock.count {
                self.loadDataStopFlg = true
            }
            ///トークリスト配列を一個ずつ回す
            for data in USERSLISTMOCK {
                ///サーバーから取得したユーザーのUIDがあったらそのIndexNoを取得
                let indexNo = self.UserListMock.firstIndex(where: { $0.UID == data.UID })
                ///配列にある古いデータを削除
                if let indexNo = indexNo{
                    self.UserListMock.remove(at: indexNo)
                }
                ///サーバーから取得したデータを配列に入れ直す
                self.UserListMock.append(UserListStruct(UID: data.UID, userNickName: data.userNickName, aboutMessage: data.aboutMessage, Age: data.Age, From: data.From!, Sex: data.Sex))
            }
            ///ロードフラグをTrue
            self.loadDataLockFlg = true
            ///テーブルビューリロード処理
            self.CHATUSERLISTTABLEVIEW.reloadData()
            
            
        }, CountLimit: limitCount)
    }
}

extension UserListViewController:UserListTableViewCellDelegate{
    func likebuttonPushed(LIKEBUTTONIMAGEVIEW: UIImageView) {
        LIKEBUTTONIMAGEVIEW.image = UIImage(named: "LIKEBUTTON_IMAGE_Pushed")
    }
}
