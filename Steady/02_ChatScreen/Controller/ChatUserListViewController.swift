//
//  ChatUserListViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/09/08.
//

import Foundation
import UIKit
import Firebase
import RealmSwift
import GoogleMobileAds
import AudioToolbox

protocol ChatUserListVCForMeinTabBarVCDelegate:AnyObject {
    func listnerDelegate(SelectedChatVC:Bool)
}

//チャット一覧画面
class ChatUserListViewController:UIViewController,UINavigationControllerDelegate{
    //++変数宣言　クロージャー++//
    let CHATUSERLISTTABLEVIEW = UITableView() ///テーブルビューのインスタンス化
    var SELFINFO:RequiredProfileInfoLocalData ///自身の情報
    var CONTENTSHOSTINGGETTER = ContentsHostGetter()
    let CONTENTSLOCALGETTER = ImageDataLocalGetterManager()
    let PLOFILEHOSTGETTER = ProfileHostGetter()
    let LISTDATAHOSTSETTER = ListDataHostSetter()
    let BLOCKHOSTGETTER = BlockHostGetterManager() ///ブロック情報を取得するインスタンス
    var USERSPROFILEARRAY:[RequiredListInfoLocalData] = []
    var BLOCKUSERIDLISTARRAY:[BlockUserObj] = []
    let ROOMID = chatTools()    ///相手との一意ID作成インスタンス
    let Tool = TIME()
    let tabBarHeight:CGFloat    ///タブバーの高さ
    let defaultInsets:UIEdgeInsets  ///表示位置の基準
    var bannerAdsView:GADBannerView = GADBannerView() ///バナー広告
    private var containerView: UIView!  ///コンテナView
    var SELFIMAGEOBJECT:listUsersImageLocalObject{  ///自身の画像取得
        get {
            return CONTENTSLOCALGETTER.getter(targetUID: SELFINFO.Required_UID) ?? listUsersImageLocalObject()
        }
    }
    var greaterThanOrEqualTime:Date {
        get {
            ///配列から一番最新の時間を取得してくる
            if let latestTime = USERSPROFILEARRAY.sorted(by: {$0.Required_DateUpdatedAt > $1.Required_DateUpdatedAt}).first?.Required_DateUpdatedAt {
                return latestTime
            } else {
                return Date()
            }
        }
    }    ///ローカルデータの最新取得時間
    weak var delegate:ChatUserListVCForMeinTabBarVCDelegate?
    
    init(tabBarHeight:CGFloat,SELFINFO:RequiredProfileInfoLocalData) {
        self.SELFINFO = SELFINFO
        self.tabBarHeight = tabBarHeight
        self.defaultInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight, right: 0)
        super.init(nibName: nil, bundle: nil)
        ///ローカルの保存データからデータ取得してリスト配列に格納
        USERSPROFILEARRAY = RequiredListInfoLocalDataGet()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setUp() {
        ///テーブルビューレイアウト
        CHATUSERLISTTABLEVIEW.backgroundColor = .white
        CHATUSERLISTTABLEVIEW.contentInset = defaultInsets
        CHATUSERLISTTABLEVIEW.scrollIndicatorInsets = defaultInsets
        ///コンテナビュー他View等の設定
        containerViewSetUp()
//        self.view = CHATUSERLISTTABLEVIEW
        ///テーブルビューのデリゲート処理
        CHATUSERLISTTABLEVIEW.dataSource = self
        CHATUSERLISTTABLEVIEW.delegate = self
        ///ナビゲーションバーセットアップ
        navigationBarSetUp()
        ///セルの登録
        CHATUSERLISTTABLEVIEW.register(ChatUserListTableViewCell.self, forCellReuseIdentifier: "chatUserListTableViewCell")

        ///ブロックユーザーの取得
        BLOCKHOSTGETTER.blockUserListListener(callback: { BlockList in
            self.BLOCKUSERIDLISTARRAY = []
            self.BLOCKUSERIDLISTARRAY = BlockList
            ///ブロックユーザーが確認でき次第リスナー開始
            self.chatListListener(greaterThanOrEqualTime: self.greaterThanOrEqualTime)
            ///テーブルビューをリロードする
            self.CHATUSERLISTTABLEVIEW.reloadData()
        }, UID: SELFINFO.Required_UID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.listnerDelegate(SelectedChatVC: true)
        ///広告表示
        mobAdsViewSetting()
        ///現在チャット中の相手のUIDをRemove
        UserDefaults.standard.set("", forKey: "chatingTargetUID")
        // バッジの数をリセット
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

//EXTENSION[UITableView関連]
extension ChatUserListViewController:UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return USERSPROFILEARRAY.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ///cellのインデックス番号の箇所のユーザー情報格納
        let CHATUSERLISTINFO = USERSPROFILEARRAY[indexPath.row]
        ///セルのインスタンス化
        var cell = tableView.dequeueReusableCell(withIdentifier: "chatUserListTableViewCell", for: indexPath ) as! ChatUserListTableViewCell
        
        ///ユーザーデータをセルに投入
        cell.CellListInfoLocalData = CHATUSERLISTINFO
        ///新着メッセージアイコン設定（送った相手が自分じゃなくて相手の場合）
        if CHATUSERLISTINFO.Required_nortificationIconFlag {
            cell.nortificationImageSetting()
        } else {
            cell.nortificationImageRemove()
        }
        ///プロフィール画像設定
        userProfileImageDataSetting(cell: cell)
        ///なんらかの関係でメインスレッド処理で基本情報設定を行わないいけない
        DispatchQueue.main.async {
            ///基本情報設定
            cell = self.ChatListUsersInfoSetting(cell: cell, LOCALCHATLISTINFO: CHATUSERLISTINFO)
        }
        ///セルの選択状態の不可
        cell.selectionStyle = .none

        return cell
    }
    
    /// セルのプロフィール画像設定(非同期処理のためすでにあるセルに対して処理を行う)
    /// - Parameters:
    ///   - cell: cellForRowAtで処理する対象のセル
    ///   - TARGETCELLID: cellForRowAtで処理する対象のユーザーUID
    func userProfileImageDataSetting(cell:ChatUserListTableViewCell) {
        let TargetUID = cell.CellListInfoLocalData.Required_targetUID
        let TOOL = TIME()
        guard let LocalImageObject = CONTENTSLOCALGETTER.getter(targetUID:TargetUID) else {
            ///画像サーバーに対して画像取得要求
            self.CONTENTSHOSTINGGETTER.MappingDataGetter(callback: { imageObject, err in
                if cell.CellListInfoLocalData.Required_targetUID == imageObject.lcl_UID {
                    ///取得した画像データをプロフィール画像に設定
                    cell.talkListUserProfileImageView.image = imageObject.profileImage
                    ///画像をローカルに保存
                    let updateImageObject = listUsersImageLocalObject()
                    updateImageObject.lcl_UpdataDate = imageObject.lcl_UpdataDate
                    updateImageObject.lcl_UID = TargetUID
                    updateImageObject.profileImage = imageObject.profileImage
                    var CONTETSLOCALSETTER = ImageDataLocalSetterManager(updateImage: updateImageObject)
                    ///コミット
                    CONTETSLOCALSETTER.commiting = true
                }
            }, UID: TargetUID, UpdateTime: TOOL.pastTimeGet())
            return
        }
        ///ローカルから取得した画像データをプロフィール画像に設定
        cell.talkListUserProfileImageView.image = LocalImageObject.profileImage
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
        ///選んだセルの相手のデータを取得
        let TargetProfile = self.USERSPROFILEARRAY[indexPath.row]
        ///相手のプロフィール画像格納
        let TARGETPROFILEIMAGE:UIImage
        ///セル情報を取得
        /// 選択された行に対応するセルを取得
        guard let cell = tableView.cellForRow(at: indexPath) as? ChatUserListTableViewCell else {
            createSheet(for: .Retry(title: "ユーザー情報の取得に失敗しました"), SelfViewController: self)
            return
        }
        // cellの通知画像を取り除く
        cell.nortificationImageRemove()
        ///相手のプロフィール画像を格納
        TARGETPROFILEIMAGE = cell.talkListUserProfileImageView.image ?? UIImage(named: "defProfile")!
        ///通知フラグをFalseにしてローカル保存
        TargetProfile.Required_nortificationIconFlag = false
        if let TargetLocalProfile = chatListLocalDataMapping(RequiredListInfoLocalData: TargetProfile) {
            RequiredListInfoLocalDataSave(TARGET: TargetLocalProfile)
        }

        ///UIDを取得
        let TARGETUID = TargetProfile.Required_targetUID
        ///タップした時点で相手の最新の情報を取得する
        PLOFILEHOSTGETTER.mappingDataGetter(callback: { InfoLocal, err in
            if err == nil {
                ///安全なデータにマッピング
                guard let TARGETPROFILE = realmMapping.profileDataMapping(PROFILE: InfoLocal,VC: self) else {
                    return
                }
                ///遷移先の画面
                let chatViewController = ChatViewController(selfProfile: self.SELFINFO, targetProfile: TARGETPROFILE, SELFPROFILEIMAGE: self.SELFIMAGEOBJECT.profileImage, TARGETPROFILEIMAGE: TARGETPROFILEIMAGE)
                chatViewController.delegate = self
                let UINavigationController = UINavigationController(rootViewController: chatViewController)
                UINavigationController.modalPresentationStyle = .fullScreen
                self.present(UINavigationController, animated: false, completion: nil)
                self.slideInFromRight() // 遷移先の画面を横スライドで表示
            } else {

            }
        }, UID: TARGETUID)
    }
    
}

///EXTENSION[ネットワーク通信関連]
extension ChatUserListViewController {
    
    ///リスナーで監視取得
    func chatListListener(greaterThanOrEqualTime:Date) {
        ///リスナーインスタンス化
        let listener = ChatListListenerManager()
        ///監視開始
        listener.chatUserListDataListener(callback: { ChatListInfoArray, err in
            if err != nil {
                return
            }
            if ChatListInfoArray.count == 0 || ChatListInfoArray.first == nil {
                return
            }

            ///取得してきたトークユーザーの配列を回す
            for listProfile in ChatListInfoArray {
                if !self.duplicationMessageChecking(profileLocal: listProfile) {
                    continue
                }
                ///ブロックユーザーに該当しており尚且つブロックしていたら追加しない
                if let BlockUser = self.BLOCKUSERIDLISTARRAY.first(where: {$0.UID == listProfile.lcl_TargetUID}) {
                    if BlockUser.KIND == .IBlocked {
                       continue
                    }
                }
                ///送信者が自身のUIDでない場合
                if self.SELFINFO.Required_UID != listProfile.lcl_SendID {
                    ///タブViewcontrollerにDelegate
                    self.delegate?.listnerDelegate(SelectedChatVC: false)
                    ///バイブレーション機能がオン設定または行なっていない場合&
                    ///チャット画面に表示している相手でない場合&
                    ///(defaluts値の関係上falseでバイブレーションするようにしている)
                    ///アプリがアクティブ（バックグラウンドでない状態）
                    if !UserDefaults.standard.bool(forKey: "vibrationToggleKey") && UserDefaults.standard.string(forKey: "chatingTargetUID") != listProfile.lcl_SendID &&
                        UIApplication.shared.applicationState == .active {
                        ///バイブレーションを起動
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    }
                    ///通知フラグを立てる
                    listProfile.lcl_nortificationIconFlag = true
                }
                
                ///マッピングに失敗した場合は追加しない
                guard let SafeChatListData = self.chatListDataSafeMapping(ChatListData: listProfile) else {
                    continue
                }
                ///既にトーク配列に存在していたら一度配列から削除
                if let index = self.USERSPROFILEARRAY.firstIndex(where: { $0.Required_targetUID == listProfile.lcl_TargetUID }) {
                    // 条件を満たす要素が見つかった場合、その要素を削除
                    self.USERSPROFILEARRAY.remove(at: index)
                }
                ///配列に追加
                self.USERSPROFILEARRAY.insert(SafeChatListData, at: 0)
                ///既読をつける
                self.LISTDATAHOSTSETTER.talkListNewMessageReaded(selfUID: self.SELFINFO.Required_UID, targetUID: SafeChatListData.Required_targetUID)
                ///ローカルに保存
                self.RequiredListInfoLocalDataSave(TARGET: listProfile)

            }
            ///テーブルビューをリロードする
            self.CHATUSERLISTTABLEVIEW.reloadData()
       
        }, UID: SELFINFO.Required_UID, greaterThanDate: greaterThanOrEqualTime)
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
    
    /// 安全な型データを保存するためのローカルデータに変換
    /// - Parameter RequiredListInfoLocalData: 安全な型データ
    /// - Returns: 保存するためのRealmデータ
    func chatListLocalDataMapping(RequiredListInfoLocalData:RequiredListInfoLocalData) -> ChatInfoDataLocalObject? {
        var Localdata = ChatInfoDataLocalObject()
        Localdata.lcl_TargetUID = RequiredListInfoLocalData.Required_targetUID
        Localdata.lcl_FirstMessage = RequiredListInfoLocalData.Required_FirstMessage
        Localdata.lcl_DateUpdatedAt = RequiredListInfoLocalData.Required_DateUpdatedAt
        Localdata.lcl_likeButtonFLAG = RequiredListInfoLocalData.Required_likeButtonFLAG
        Localdata.lcl_SendID = RequiredListInfoLocalData.Required_SendID
        Localdata.lcl_meNickname = RequiredListInfoLocalData.Required_meNickname
        Localdata.lcl_youNickname = RequiredListInfoLocalData.Required_youNickname
        Localdata.lcl_nortificationIconFlag = RequiredListInfoLocalData.Required_nortificationIconFlag
        return Localdata
    }
}
///EXTENSION[ローカルデータ関連]
extension ChatUserListViewController {
    ///
    ///特定のチャットリストデータを保存する
    func RequiredListInfoLocalDataSave(TARGET:ChatInfoDataLocalObject) {
        ///保存マネージャー
        var saveObject = ChatInfoDataSetterManager(updateProfile: TARGET)
        ///保存
        saveObject.commiting = true
    }
    ///保存してあるチャットリストデータを取得する
    func RequiredListInfoLocalDataGet() -> [RequiredListInfoLocalData] {
        ///取得マネージャー
        var getObjects = ChatInfoLocalDataGetterManager()
        ///安全な型配列
        var safeListInfoArray:[RequiredListInfoLocalData] = []
        ///保存データを一つずつ処理
        for object in getObjects.AllGetter() {
            ///安全な型にマッピングできたら配列に追加
            if let mappingedData = chatListDataSafeMapping(ChatListData: object){
                safeListInfoArray.append(mappingedData)
            }
        }
        
        return safeListInfoArray
    }
    
}

///EXTENSION[NavigationBar関連]
extension ChatUserListViewController {
    /// ナビゲーションバー初期セットアップ
    func navigationBarSetUp() {
        /// カスタムのタイトルビューを作成
        let titleLabel = UILabel()
        titleLabel.text = "リスト"
        titleLabel.textColor = UIColor.gray
        /// ナビゲーションバーのタイトルビューを設定
        self.navigationItem.titleView = titleLabel
        navigationController?.navigationBar.barTintColor = UIColor.white
    }
}

//EXTENSION[他処理]

extension ChatUserListViewController:ChatViewControllerForChatListViewControllerDelegate{
    func newImageSettingDelegate(UID: String, targetImage: UIImage) {
        ///選んだセルの相手のインデックスデータを取得
        guard let Index = self.USERSPROFILEARRAY.firstIndex(where: {$0.Required_targetUID == UID}) else {
            return
        }
        
        let indexPath = IndexPath(row: Index, section: 0)

        ///配列からユーザーを取得して通知アイコンの通知をオフに
        self.USERSPROFILEARRAY.first(where: {$0.Required_targetUID == UID})?.Required_nortificationIconFlag = false
        ///特定のセルのみ再リロード
        CHATUSERLISTTABLEVIEW.reloadRows(at: [indexPath], with: .automatic)
    }
    
    ///重複したデータを取得してきていたらチェック
    func duplicationMessageChecking(profileLocal:ChatInfoDataLocalObject) -> Bool {
        var profile = self.USERSPROFILEARRAY.first(where: {$0.Required_DateUpdatedAt == profileLocal.lcl_DateUpdatedAt})
        
        if profile?.Required_targetUID == profileLocal.lcl_TargetUID &&
            profile?.Required_FirstMessage == profileLocal.lcl_FirstMessage {
            return false
        }
        return true
    }
}
///その他の処理
extension ChatUserListViewController {
    //コンテナビュー他メインの階層表示設定
    func containerViewSetUp() {
        ///コンテナビューを画面に追加
        containerView = UIView()
        containerView.backgroundColor = .white
        self.view.addSubview(containerView)
        // Auto LayoutでContainerViewを配置
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true

        containerView.addSubview(CHATUSERLISTTABLEVIEW) ///追記
        ///テーブルビューもレイアウトを合わせておく
        CHATUSERLISTTABLEVIEW.translatesAutoresizingMaskIntoConstraints = false
        CHATUSERLISTTABLEVIEW.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        CHATUSERLISTTABLEVIEW.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        CHATUSERLISTTABLEVIEW.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        CHATUSERLISTTABLEVIEW.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
}

///広告の実装
extension ChatUserListViewController {
    ///バナー広告
    func mobAdsViewSetting() {
        bannerAdsView.adUnitID = ADSInfoSingleton.shared.bannerAdUnitID     /// 追記
        bannerAdsView.rootViewController = self      /// 追記
        // 広告読み込み
        bannerAdsView.load(GADRequest())              /// 追記
        
        self.view.addSubview(bannerAdsView)
        bannerAdsView.translatesAutoresizingMaskIntoConstraints = false
    
        // self.tabBarHeightの高さを足す
        
        bannerAdsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bannerAdsView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        bannerAdsView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        bannerAdsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
}
