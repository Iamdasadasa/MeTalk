//
//  ChatUserListViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/11/06.
//

import Foundation
import UIKit
import Firebase
import RealmSwift
import MessageKit

//チャット一覧画面
class TargetChatUserListViewController:UIViewController,UINavigationControllerDelegate{
    //++変数宣言　クロージャー++//
    let CHATUSERLISTTABLEVIEW = UITableView() ///テーブルビューのインスタンス化
    var SELFINFO:RequiredProfileInfoLocalData ///自身の情報
    var SELFIMAGEOBJECT:listUsersImageLocalObject
    var CONTENTSHOSTINGGETTER = ContentsHostGetter()
    let CONTENTSLOCALGETTER = ImageDataLocalGetterManager()
    let PLOFILEHOSTGETTER = ProfileHostGetter()
    let USERLISTGETTER = adminHostGetterManager()
    var USERSPROFILEARRAY:[RequiredListInfoLocalData] = []
    let ROOMID = chatTools()    ///相手との一意ID作成インスタンス
    let Tool = TIME()
    let tabBarHeight:CGFloat    ///タブバーの高さ
    let defaultInsets:UIEdgeInsets  ///表示位置の基準
    let dammyUserListFlag:Bool
    
    init(tabBarHeight:CGFloat,SELFINFO:RequiredProfileInfoLocalData,SELFIMAGEOBJECT:listUsersImageLocalObject,dammyUserListFlag:Bool) {
        self.SELFINFO = SELFINFO
        self.tabBarHeight = tabBarHeight
        self.SELFIMAGEOBJECT = SELFIMAGEOBJECT
        self.defaultInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight, right: 0)
        self.dammyUserListFlag = dammyUserListFlag
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        ///テーブルビューレイアウト
        CHATUSERLISTTABLEVIEW.backgroundColor = .white
        CHATUSERLISTTABLEVIEW.contentInset = defaultInsets
        CHATUSERLISTTABLEVIEW.scrollIndicatorInsets = defaultInsets
        self.view = CHATUSERLISTTABLEVIEW
        ///テーブルビューのデリゲート処理
        CHATUSERLISTTABLEVIEW.dataSource = self
        CHATUSERLISTTABLEVIEW.delegate = self
        ///ナビゲーションバーセットアップ
        navigationBarSetUp()
        ///セルの登録
        CHATUSERLISTTABLEVIEW.register(ChatUserListTableViewCell.self, forCellReuseIdentifier: "chatUserListTableViewCell")
        ///リスト取得開始
        chatListGetter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
}

//EXTENSION[UITableView関連]
extension TargetChatUserListViewController:UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return USERSPROFILEARRAY.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ///cellのインデックス番号の箇所のユーザー情報格納
        let CHATUSERLISTINFO = USERSPROFILEARRAY[indexPath.row]
        ///セルのインスタンス化
        var cell = tableView.dequeueReusableCell(withIdentifier: "chatUserListTableViewCell", for: indexPath ) as! ChatUserListTableViewCell
        
        ///ユーザーデータをセルに投入
        cell.CellListInfoLocalData = CHATUSERLISTINFO
        ///プロフィール画像設定
        userProfileImageDataSetting(cell: cell)
        ///なんらかの関係でメインスレッド処理で基本情報設定を行わないいけない
        DispatchQueue.main.async {
            ///基本情報設定
            cell = self.ChatListUsersInfoSetting(cell: cell, LOCALCHATLISTINFO: CHATUSERLISTINFO)
        }

        return cell
    }
    
    /// セルのプロフィール画像設定(非同期処理のためすでにあるセルに対して処理を行う)
    /// - Parameters:
    ///   - cell: cellForRowAtで処理する対象のセル
    ///   - TARGETCELLID: cellForRowAtで処理する対象のユーザーUID
    func userProfileImageDataSetting(cell:ChatUserListTableViewCell) {
        let TargetUID = cell.CellListInfoLocalData.Required_targetUID
        let TOOL = TIME()
            ///画像サーバーに対して画像取得要求
            self.CONTENTSHOSTINGGETTER.MappingDataGetter(callback: { imageObject, err in
                if cell.CellListInfoLocalData.Required_targetUID == imageObject.lcl_UID {
                    ///取得した画像データをプロフィール画像に設定
                    cell.talkListUserProfileImageView.image = imageObject.profileImage
                }
            }, UID: TargetUID, UpdateTime: TOOL.pastTimeGet())
    }
    
    /// ユーザープロフィール
    /// - Parameters:
    ///   - cell: cellForRowAtで処理する対象のセル
    ///   - LOCALUSERSPROFILE: cellForRowAtで処理する対象のユーザー情報
    /// - Returns: 基本情報の設定が完了したセル
    func ChatListUsersInfoSetting(cell:ChatUserListTableViewCell,LOCALCHATLISTINFO:RequiredListInfoLocalData) -> ChatUserListTableViewCell{
        ///セルのIDと配列のIDが合致した時のみ
        if cell.CellListInfoLocalData.Required_targetUID == LOCALCHATLISTINFO.Required_targetUID {
            ///新しいメッセージ
            cell.newMessageSetCell(Item: LOCALCHATLISTINFO.Required_FirstMessage)
            ///相手のニックネーム
            cell.nickNameSetCell(Item: LOCALCHATLISTINFO.Required_youNickname)
            ///受信時間
            ///　時間を文字列に変換
            let displayTimeValue = TimeCalculator.calculateTimeDisplay(from: LOCALCHATLISTINFO.Required_DateUpdatedAt)
            cell.receivedTimeLabelSetCell(Item: displayTimeValue)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ///選んだセルの相手のUIDを取得
        let TARGETUID = self.USERSPROFILEARRAY[indexPath.row].Required_targetUID
        ///相手のプロフィール画像格納
        let TARGETPROFILEIMAGE:UIImage
        /// 選択された行に対応するセルを取得
        guard let cell = tableView.cellForRow(at: indexPath) as? ChatUserListTableViewCell else {
            createSheet(for: .Retry(title: "ユーザー情報の取得に失敗しました"), SelfViewController: self)
            return
        }
        ///相手のプロフィール画像を格納
        TARGETPROFILEIMAGE = cell.talkListUserProfileImageView.image ?? UIImage(named: "defProfile")!
        ///タップした時点で相手の最新の情報を取得する
        PLOFILEHOSTGETTER.mappingDataGetter(callback: { InfoLocal, err in
            if err == nil {
                ///安全なデータにマッピング
                guard let TARGETPROFILE = realmMapping.profileDataMapping(PROFILE: InfoLocal,VC: self) else {
                    return
                }
                var chatViewController:MessagesViewController?
                ///遷移先の画面
                if self.dammyUserListFlag {
                    chatViewController = ChatViewController(selfProfile: self.SELFINFO, targetProfile: TARGETPROFILE, SELFPROFILEIMAGE: self.SELFIMAGEOBJECT.profileImage, TARGETPROFILEIMAGE: cell.talkListUserProfileImageView.image ?? TARGETPROFILEIMAGE)
                } else {
                    chatViewController = AdminUserCheckingChatViewController(selfProfile: self.SELFINFO, targetProfile: TARGETPROFILE, SELFPROFILEIMAGE: self.SELFIMAGEOBJECT.profileImage)
                    chatViewController!.messageInputBar.inputTextView.placeholder = "最新30件まで表示中。管理者画面では操作できません。"
                }

                let UINavigationController = UINavigationController(rootViewController: chatViewController!)
                UINavigationController.modalPresentationStyle = .fullScreen
                self.present(UINavigationController, animated: false, completion: nil)
                self.slideInFromRight() // 遷移先の画面を横スライドで表示
            } else {

            }
        }, UID: TARGETUID)
    }
    
}

///EXTENSION[ネットワーク通信関連]
extension TargetChatUserListViewController {
    
    ///リストユーザー取得
    func chatListGetter() {
        USERLISTGETTER.targetChatUserListDataGetter(callback: { ChatListInfo, err in
            if err != nil {
                return
            }
            
            for userInfo in ChatListInfo {
                ///マッピングに失敗した場合は追加しない
                guard let SafeChatListData = self.chatListDataSafeMapping(ChatListData: userInfo) else {
                    return
                }
                ///既にトーク配列に存在していたら一度配列から削除
                if let index = self.USERSPROFILEARRAY.firstIndex(where: { $0.Required_targetUID == userInfo.lcl_TargetUID }) {
                    // 条件を満たす要素が見つかった場合、その要素を削除
                    self.USERSPROFILEARRAY.remove(at: index)
                }


                ///配列に追加
                self.USERSPROFILEARRAY.insert(SafeChatListData, at: 0)
            }
            ///テーブルビューをリロードする
            self.CHATUSERLISTTABLEVIEW.reloadData()
            
        }, UID: SELFINFO.Required_UID, dammy: dammyUserListFlag)
    }
    
    /// リスナーで取得してきたデータを安全な型に変換(リストデータ)
    /// - Parameter PROFILE: リスナーで取得したデータ
    /// - Returns: 安全な型
    func chatListDataSafeMapping(ChatListData:ChatInfoDataLocalObject) -> RequiredListInfoLocalData? {
        /// データ不備が一つでもあれば追加しない
        guard let TARGETUID = ChatListData.lcl_TargetUID,let SENDUID = ChatListData.lcl_SendID,let FirstMessage = ChatListData.lcl_FirstMessage,let meNickName = ChatListData.lcl_meNickname,let youNickname = ChatListData.lcl_youNickname,let DateUpdateAt = ChatListData.lcl_DateUpdatedAt else {
            return nil
        }
        var firstMessage:String = FirstMessage
        if ChatListData.lcl_likeButtonFLAG {
            firstMessage = "⭐️"
        }
        
        ///安全なデータとして格納
        let RequiredChatListData = RequiredListInfoLocalData(targetUID: TARGETUID, SendID: SENDUID, FirstMessage: firstMessage, likeButtonFLAG: ChatListData.lcl_likeButtonFLAG, meNickname: meNickName, youNickname: youNickname, DateUpdatedAt: DateUpdateAt, nortificationIconFlag: ChatListData.lcl_nortificationIconFlag)
        return RequiredChatListData
    }
}

///EXTENSION[NavigationBar関連]
extension TargetChatUserListViewController {
    /// ナビゲーションバー初期セットアップ
    func navigationBarSetUp() {
        /// カスタムのタイトルビューを作成
        let titleLabel = UILabel()
        titleLabel.text = "リスト"
        titleLabel.textColor = UIColor.black
        /// ナビゲーションバーのタイトルビューを設定
        self.navigationItem.titleView = titleLabel
    }
    
}
