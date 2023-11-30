//
//  showUserListVoewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/06/08.
//

import Foundation
import UIKit
import Firebase
import RealmSwift
import CoreAudio
//ユーザー一覧画面
class showUserListViewController:UIViewController,UINavigationControllerDelegate{
    //++変数宣言　クロージャー++//
    let CHATUSERLISTTABLEVIEW = UITableView()   ///Viewのインスタンス化
    let SEARCHVIEWCONTROLLER = SearchSettingViewController()    ///検索画面インスタンス化
    let CHATDATAHOSTSETTER = ChatDataHostSetterManager()    ///チャットデータを保存するインスタンス(FIREBASE)
    let LISTDATAHOSTSETTER = ListDataHostSetter()   ///リストデータを保存するインスタンス(FIREBASE)
    let TALKLISTDATAHOSTGETTER = TalkListGetterManager()    ///トークリストのユーザーを取得するインスタンス(FIREBASE)
    let CONTENTSHOSTINGSETTER = ContentsHostSetter()    ///画像データを保存するインスタンス(FIREBASE)
    let CONTENTSHOSTINGGETTER = ContentsHostGetter()    ///画像データを取得するインスタンス(FIREBASE)
    let PERFORMSEARCHLOCALGETTER = PerformSearchLocalDataGetterManager()
    let BLOCKHOSTGETTER = BlockHostGetterManager() ///ブロック情報を取得するインスタンス
    ///検索条件を取得するインスタンス(Realm)
    var QUERY:QueryFilter = QueryFilter(minAge: nil, maxAge: nil, gender: nil, area: nil)   ///検索条件を管理するインスタンス
    let APIKEYLOCALGETTER :ApiKeyDataLocalGetterManager = ApiKeyDataLocalGetterManager()    ///Apiキー関連
    var USERSPROFILEARRAY:[RequiredProfileInfoLocalData] = []  ///ユーザー一覧格納配列
    var SELFINFO:RequiredProfileInfoLocalData ///自身の情報
    let ROOMID = chatTools()    ///相手との一意ID作成インスタンス
    let tabBarHeight:CGFloat    ///タブバーの高さ
    let defaultInsets:UIEdgeInsets  ///表示位置の基準
    let activityIndicatorView = UIActivityIndicatorView(style: .large)      ///インジケータロードビュー
    let loading = LOADING(loadingView: LoadingView(), BackClear: true)  ///画面ロードビュー
    var isReadyToLoadPosition:Bool = false  ///スクロール完全停止フラグ
    var scrollServerAccessPermFlag:Bool = true  ///サーバーアクセス停止フラグ
    var selectingCell = UserListTableViewCell() ///現在選択中のセル
    let cache = NSCache<NSString, UIImage>()    ///画像データ用のキャッシュ
    let TIMETOOL = TimeTools()
    var reloading = true {   ///ユーザーローディングフラグ
        ///ロードインジケータ表示可否
        willSet {
            if newValue {
                ///インジケータ非表示
                ActivityIndicatorShow(showing: false)
                self.loading.loadingViewIndicator(isVisible: false)
            } else {
                ///インジケータ表示
                ActivityIndicatorShow(showing: true)
            }
        }
    }
    var BLOCKUSERIDLISTARRAY:[BlockUserObj] = [] {    ///ブロックユーザーの格納リスト
        willSet {
            ///ブロックユーザーを確認
            for BlockUser in newValue {
                ///配列に存在しているかを確認
                if let index = self.USERSPROFILEARRAY.firstIndex(where: { $0.Required_UID == BlockUser.UID }) {
                    let indexPath = IndexPath(row: index, section: 0) // セクション0の指定行のIndexPathを作成
                    self.USERSPROFILEARRAY.remove(at: index)
                    ///テーブルから削除
                    CHATUSERLISTTABLEVIEW.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    init(tabBarHeight:CGFloat,SELFINFO:RequiredProfileInfoLocalData) {
        
        self.SELFINFO = SELFINFO
        self.tabBarHeight = tabBarHeight
        self.defaultInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight, right: 0)
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
        ///検索画面のデリゲート委任
        SEARCHVIEWCONTROLLER.delegate = self
        ///ナビゲーションバーセットアップ
        navigationBarSetUp()
        ///インジケータレイアウト
        activityIndicatorView.color = UIColor.gray
        ///インジケータの余白を設定
        self.CHATUSERLISTTABLEVIEW.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        // スクロールビューの下方向への引っ張りを監視する
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        CHATUSERLISTTABLEVIEW.refreshControl = refreshControl
        ///セルの登録
        CHATUSERLISTTABLEVIEW.register(UserListTableViewCell.self, forCellReuseIdentifier: "UserListTableViewCell")
        
//        /// データリロード
        self.basicReloadData()
        ///ブロックユーザーの取得
        BLOCKHOSTGETTER.blockUserListListener(callback: { BlockList in
            self.BLOCKUSERIDLISTARRAY = []
            self.BLOCKUSERIDLISTARRAY = BlockList
        }, UID: SELFINFO.Required_UID)
    }
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
    }
}
//EXTENSION[UITableView関連]
extension showUserListViewController:UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return USERSPROFILEARRAY.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ///セルのインスタンス化
        var cell = tableView.dequeueReusableCell(withIdentifier: "UserListTableViewCell", for: indexPath ) as! UserListTableViewCell
        ///cellのインデックス番号の箇所のユーザー情報格納
        let PROFILEINFOLOCAL = USERSPROFILEARRAY[indexPath.row]
        
        cell.celluserStruct = PROFILEINFOLOCAL

        ///基本情報設定
        cell = usersProfileSetting(cell: cell,LOCALUSERSPROFILE: PROFILEINFOLOCAL)
        ///プロフィール画像設定
        userProfileImageDataSetting(cell: cell,TARGETCELLID: PROFILEINFOLOCAL.Required_UID)
        ///ライクボタン設定
        likeButtonSetting(cell: cell)
        ///セルのデリゲート設定
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// 選択された行のセルを一時的に取得
        guard let cell = tableView.cellForRow(at: indexPath) as? UserListTableViewCell else {
            createSheet(for: .Retry(title: "選択したユーザー情報を取得できませんでした"), SelfViewController: self)
            return
        }
        let targetProfileViewController = ProfileViewController(TARGETINFO: USERSPROFILEARRAY[indexPath.row], SELFINFO: SELFINFO, TARGETIMAGE: cell.profileImageView.image ?? UIImage(named: "defProfile")!)

        selectingCell = cell
        ///デリゲートを設定
        targetProfileViewController.delegate = self
        targetProfileViewController.PROFILEVIEW.TargetProfileLikeButtonTappedDelegate = self
        targetProfileViewController.modalPresentationStyle = .fullScreen
        self.present(targetProfileViewController, animated: false, completion: nil)
        self.slideInFromRight() // 遷移先の画面を横スライドで表示
    }
    
    /// セルのプロフィール画像設定(非同期処理のためすでにあるセルに対して処理を行う)
    /// - Parameters:
    ///   - cell: cellForRowAtで処理する対象のセル
    ///   - TARGETCELLID: cellForRowAtで処理する対象のユーザーUID
    func userProfileImageDataSetting(cell:UserListTableViewCell,TARGETCELLID:String) {
        ///キャッシュ用に変換したID
        let cacheID = NSString(string: TARGETCELLID)
        ///キャッシュ画像設定
        if let cacheImage = cache.object(forKey: cacheID) {
            cell.profileImageView.image = cacheImage
        } else {
            ///キャッシュに存在していなければサーバー取得
            let TOOL = TIME()
            ///画像サーバーに対して画像取得要求
            self.CONTENTSHOSTINGGETTER.MappingDataGetter(callback: { imageObject, err in
                ///取得した画像データをキャッシュに保存
                self.cache.setObject(imageObject.profileImage, forKey: cacheID)
                ///再利用時の誤設定を防ぐために識別処理を入れる。
                guard cell.celluserStruct.Required_UID == TARGETCELLID else {
                    return
                }
                ///取得した画像データをプロフィール画像に設定
                cell.profileImageView.image = imageObject.profileImage
            }, UID: TARGETCELLID, UpdateTime: TOOL.pastTimeGet())
        }
    }
    
    /// ユーザープロフィール
    /// - Parameters:
    ///   - cell: cellForRowAtで処理する対象のセル
    ///   - LOCALUSERSPROFILE: cellForRowAtで処理する対象のユーザー情報
    /// - Returns: 基本情報の設定が完了したセル
    func usersProfileSetting(cell:UserListTableViewCell,LOCALUSERSPROFILE:RequiredProfileInfoLocalData) -> UserListTableViewCell{
        ///ニックネーム
        cell.nickNameSetCell(Item: LOCALUSERSPROFILE.Required_NickName)
        ///ひとこと
        cell.aboutMessageSetCell(Item: LOCALUSERSPROFILE.Required_AboutMeMassage)
        ///性別
        let gender = GENDER(rawValue: LOCALUSERSPROFILE.Required_Sex) ?? .none
        cell.genderImageSetCell(gender: gender)
        ///西暦を年齢に変換
        let age = AgeCalculator.calculateAge(from: String(LOCALUSERSPROFILE.Required_Age))
            cell.ageSetCell(age: age)
        ///住まいを設定
        cell.areaSetCell(area: LOCALUSERSPROFILE.Required_Area)
        ///ログイン時間を設定
        cell.loginTimeSetCell(loginTime: TimeCalculator.calculateRemainingTime(from: LOCALUSERSPROFILE.Required_DateUpdatedAt))
        ///セルの選択状態の不可
        cell.selectionStyle = .none
        return cell
    }
    /// セルのライクボタンの設定
    /// - Parameters:
    ///   - cell: ターゲットとなるセル
    ///   - cellUID: ターゲットセルのUID
    ///   - TARGETCELLID: 表示するべきユーザーのUID
    func likeButtonSetting(cell:UserListTableViewCell) {
        if cell.celluserStruct.Required_LikeButtonPushedFLAG {
            cell.likePush = true
        } else {
            cell.likePush = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ///スクロールが最下層に来た場合の判別
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        let tabbarHeight = tabBarController?.tabBar.frame.size.height ?? 0
        ///最下層到達
        if distanceFromBottom + (tabbarHeight)  < height {
            ///フラグオン
            isReadyToLoadPosition = true
        } else {
            ///フラグオフ
            isReadyToLoadPosition = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        ///スクロール完全停止時
        if isReadyToLoadPosition {
            ///最下層に到達している
            if self.reloading && self.scrollServerAccessPermFlag {
                ///スクロールカウンターを追加
                self.QUERY.scrollCounter = self.QUERY.scrollCounter + 1
                // デリゲートは何回も呼ばれてしまうので、リロード中はfalseにしておく
                self.reloading = false
                ///ユーザー情報取得
                self.userDataServerGetting(filter: self.QUERY)
            }
        }
    }
}

//EXTENSION[画面上のボタンを押下時のアクション関連]
extension showUserListViewController:UserListTableViewCellDelegate {
    
    /// 画面上のライクボタンを押下した際の処理
    /// - Parameters:
    ///   - CELL: 対象のセルそのもの
    ///   - CELLUSERSTRUCT: 対象のセルに格納されているプロフィールデータ
    func likebuttonPushed(CELL: UserListTableViewCell, CELLUSERSTRUCT: RequiredProfileInfoLocalData) {
        CELL.likeAnimationPlay()
        ///アニメーション中に連続押下防止
        CELL.LikeButton.isEnabled = false
        ///ライクデータ更新
        LikeButtonPushedInfoUpdate(CELL: CELL)
        ///セル再利用時に正しい押下データになるようデータ格納
        guard let ArrayInTargetProfile = self.USERSPROFILEARRAY.first(where: {$0.Required_UID == CELLUSERSTRUCT.Required_UID}) else {
            return
        }
        ArrayInTargetProfile.Required_LikeButtonPushedDate = Date()
        ArrayInTargetProfile.Required_LikeButtonPushedFLAG = true
    }
    
    /// 画面上のプロフィール画像を押下した際の処理
    /// - Parameters:
    ///   - CELL: 対象のセルそのもの
    ///   - CELLUSERSTRUCT: 対象のセルに格納されているプロフィールデータ
    func profileImageButtonPushed(CELL: UserListTableViewCell, CELLUSERSTRUCT: RequiredProfileInfoLocalData) {
        print("プロフィール写真が押下されました。")
    }
    
    /// ライクボタンを押下した際のデータ関連の処理
    ///   - CELLUSERSTRUCT: 対象のセルに格納されているプロフィールデータ
    private func LikeButtonPushedInfoUpdate(CELL: UserListTableViewCell) {
        ///すべての処理が終了するまでロードインジケータ表示
        loading.loadingViewIndicator(isVisible: true)
        ///セルのユーザー情報
        guard let targetProfile = CELL.celluserStruct else {
            err(Type: .likeButtonInvalid, TargetVC: self)
            return
        }
        ///相手とのルームIDを作成
        let roomID = ROOMID.roomIDCreate(UID1: self.SELFINFO.Required_UID, UID2: targetProfile.Required_UID)
        ///更新処理
        hostAndlocalProfileDataCreateAndRegister(roomID: roomID, CELL: CELL)
    }
}
///EXTENSION[ネットワーク通信関連]
extension showUserListViewController {
    
    /// ユーザー一覧をサーバーから取得
    /// - Parameter filter: 検索条件
    func userDataServerGetting(filter:QueryFilter) {
        ///まずはAPI Keyの取得
        self.ApiKeyGetter { APPID,APIKEY,VERSION  in
            ///APIキーが取得でき次第サーバアクセスしてデータを取得
            self.TALKLISTDATAHOSTGETTER.userListDataFetching(callback: { gettingData, Err in
                let errMessage = {
                    createSheet(for: .Alert(title: "トークする人が見つかりませんでした...", message: "検索条件を変えて再度お試しください", buttonMessage: "OK", {_ in } ), SelfViewController: self)
                }
                if Err != nil {
                    self.reloading = true
                    self.scrollServerAccessPermFlag = false
                    errMessage()
                    return
                }
                ///サーバーからの取得件数が0
                if gettingData.count == 0{
                    self.reloading = true
                    self.scrollServerAccessPermFlag = false
                    errMessage()
                    return
                }
                ///一件ずつ処理
                for data in gettingData{
                    if let RequiredProfile = self.CheckingDataAndlikeDataExtra(PROFILE: data){
                        ///トークリスト配列に追加
                        self.USERSPROFILEARRAY.append(RequiredProfile)
                    }
                }
                self.reloading = true
                self.loading.loadingViewIndicator(isVisible: false)
                self.CHATUSERLISTTABLEVIEW.reloadData()
            }, appID: APPID, apiKey: APIKEY, query: filter)
        }
    }
    
    /// ライクデータをホスティングで取得してきたデータに付与
    /// - Parameter PROFILE: ホスティングで取得したデータ
    /// - Returns: ローカルに保存してあるライクデータを付与して返却
    func CheckingDataAndlikeDataExtra(PROFILE:ProfileInfoLocalObject) -> RequiredProfileInfoLocalData? {
        ///自分は除外
        if PROFILE.lcl_UID == SELFINFO.Required_UID {
            return nil
        }
        /// データ不備が一つでもあれば追加しない
        guard let UID = PROFILE.lcl_UID,let DateCreatedAt = PROFILE.lcl_DateCreatedAt,let DateUpdatedAt = PROFILE.lcl_DateUpdatedAt,let AboutMeMassage = PROFILE.lcl_AboutMeMassage,let NickName = PROFILE.lcl_NickName,let Area = PROFILE.lcl_Area else {
            return nil
        }
        ///既にトーク配列に存在しているもしくはブロックリストにいたら追加しない
        if self.USERSPROFILEARRAY.first(where: {$0.Required_UID == UID}) != nil || self.BLOCKUSERIDLISTARRAY.first(where: {$0.UID == UID}) != nil {
            return nil
        }

        ///安全なデータとして格納
        let RequiredProfile = RequiredProfileInfoLocalData(UID: UID, DateCreatedAt: DateCreatedAt, DateUpdatedAt: DateUpdatedAt, Sex: PROFILE.lcl_Sex, AboutMeMassage: AboutMeMassage, NickName: NickName, Age: PROFILE.lcl_Age, Area: Area)
        ///ローカルからライク押下データのみを最新データに反映
        let LOCALTALKLISTDATAHOSTGETTER = TargetProfileLocalDataGetterManager(targetUID: PROFILE.lcl_UID!)
        let localTargetProfile = LOCALTALKLISTDATAHOSTGETTER.getter()
        ///ライク押下データ処理
        if let pushDate = localTargetProfile?.lcl_LikeButtonPushedDate{
            RequiredProfile.Required_LikeButtonPushedDate = pushDate
            RequiredProfile.Required_LikeButtonPushedFLAG = TIMETOOL.pushTimeDiffDate(pushTime: pushDate)
            ///付与して返却
            return RequiredProfile
        } else {
            ///押下データがない場合は付与せず返却
            RequiredProfile.Required_LikeButtonPushedFLAG = false
            return RequiredProfile
        }
    }
    /// ライクボタンを押した相手の情報をローカルとサーバーに登録
    /// - Parameters:
    ///   - roomID: 一意となるトーク対象と自分のID
    ///   - targetUID: 相手のUID
    func hostAndlocalProfileDataCreateAndRegister(roomID:String,CELL:UserListTableViewCell) {
        ///コミット可否
        var CommitFlag:Bool = true
        ///セルのユーザー情報
        guard let targetProfile = CELL.celluserStruct else {
            err(Type: .likeButtonInvalid, TargetVC: self)
            return
        }
        ///Update用新規アンマネージドオブジェクト
        var UpdateProfile = ProfileInfoLocalObject()
        ///アンマネージドオブジェクトの更新対象以外をマッピング
        UpdateProfile = realmMapping.updateObjectMapping(unManagedObject: UpdateProfile, managedObject: targetProfile)
        UpdateProfile.lcl_LikeButtonPushedFLAG = true
        UpdateProfile.lcl_LikeButtonPushedDate = Date()

        ///ローカル保存開始
        var profileDataSetter = TargetProfileLocalDataSetterManager(updateProfile: UpdateProfile)
        ///サーバ処理失敗時のクロージャ
        let failedToRetry = {
            err(Type: .likeButtonInvalid, TargetVC: self)
            CELL.likePush = false
            CommitFlag = false
            ///ロードインジケータ非表示
            self.loading.loadingViewIndicator(isVisible: false)
            return
        }
        ///サーバー保存
        ///それぞれのトーク情報とチャット情報にライク情報を送信
        let message = Message(Entity: MessageEntity(message: "", senderID: self.SELFINFO.Required_UID, displayName: self.SELFINFO.Required_NickName, messageID: UUID().uuidString, sentDate:  Date(), DateGroupFlg: false, SENDUSER: .SELF))
        CHATDATAHOSTSETTER.messageUpload(callback: { err in
            ///チャット失敗
            if let err = err {
                failedToRetry()
                ///ロードインジケータ非表示
                self.loading.loadingViewIndicator(isVisible: false)
                CELL.likePush = false
                return
            }
            
            ///それぞれのトークリストを更新
            self.LISTDATAHOSTSETTER.talkListToUserInfoSetter(
                callback: {hostingresult in
                    ///トークリスト更新失敗
                    guard hostingresult else {
                        failedToRetry()
                        ///ロードインジケータ非表示
                        self.loading.loadingViewIndicator(isVisible: false)
                        CELL.likePush = false
                        return
                    }
                    ///トランザクション中のローカルデータもコミット
                    CommitFlag = true
                    ///ロードインジケータ非表示
                    self.loading.loadingViewIndicator(isVisible: false)
                    CELL.likeAnimationPlay()
                    return
                }, UID1: self.SELFINFO.Required_UID,UID2: targetProfile.Required_UID,message: "",
                sender: self.SELFINFO.Required_UID,nickName1: self.SELFINFO.Required_NickName,
                nickName2: targetProfile.Required_NickName,like: true,blocked: false
            )
            
        }, Message: message, text: "", roomID: roomID, Like: true)
        
        DispatchQueue.main.async {
            profileDataSetter.commiting = CommitFlag
        }
    }
    
    /// クエリ条件の呼び出しと適用
    func querySetting() {
        ///ローカルから検索条件を取得してクエリ変数に適用
        let queVal = PERFORMSEARCHLOCALGETTER.getter()
        ///年齢
        QUERY.minAge = queVal?.lcl_MinAge ?? 30001231
        QUERY.maxAge = queVal?.lcl_MaxAge ?? 19000101
        ///エリアが未選択の場合は条件無し
        if queVal?.lcl_Area == "未設定" {
            QUERY.area = nil
        } else {
            QUERY.area = queVal?.lcl_Area
        }

        ///性別が0(未選択の場合)は条件無し
        if queVal?.lcl_Gender == 0 {
            QUERY.gender = nil
        } else {
            QUERY.gender = queVal?.lcl_Gender ?? nil
        }
    }
    
}
///EXTENSION[NavigationBar関連]
extension showUserListViewController {
    /// ナビゲーションバー初期セットアップ
    func navigationBarSetUp() {
        /// カスタムのタイトルビューを作成
        let titleLabel = UILabel()
        titleLabel.text = "コミュニケーション"
        titleLabel.textColor = UIColor.gray
        /// ナビゲーションバーのタイトルビューを設定
        self.navigationItem.titleView = titleLabel
        ///ナビゲーションバーの背景色の設定
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        ///リロードボタン設定
        let barReloadButtonItem = barButtonItem(frame: .zero, BarButtonItemKind: .any("reload"))
        barReloadButtonItem.addTarget(self, action: #selector(reloadButtonTapped), for: .touchUpInside)
        let rightBarButtonItem = UIBarButtonItem(customView: barReloadButtonItem)
        ///リロードボタンセット
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        ///検索ボタン設定
        let barfilterButtonItem = barButtonItem(frame: .zero, BarButtonItemKind: .any("filter01"))
        barfilterButtonItem.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        let leftBarButtonItem = UIBarButtonItem(customView: barfilterButtonItem)
        ///検索ボタンセット
        self.navigationItem.leftBarButtonItem = leftBarButtonItem

    }
    ///リロードボタンタップ時のアクション
    @objc func reloadButtonTapped() {
        self.loading.loadingViewIndicator(isVisible: true)
        // データリロード
        basicReloadData()
    }
    
    ///検索ボタンタップ時のアクション
    @objc func filterButtonTapped() {
        let UINavigationController = UINavigationController(rootViewController: SEARCHVIEWCONTROLLER)
        UINavigationController.modalPresentationStyle = .fullScreen
        self.present(UINavigationController, animated: false, completion: nil)
        self.slideOutToLeft() // 遷移先の画面を横スライドで表示
    }
    
    // 引っ張り操作でのリフレッシュ処理
    @objc func refreshData() {
        reloading = false
        // データリロード
        basicReloadData()
        // リフレッシュコントロールの終了処理
        CHATUSERLISTTABLEVIEW.refreshControl?.endRefreshing()
    }
}
///EXTENSION[プロフィール画面のデリゲート]
extension showUserListViewController:ProfileViewControllerDelegate {
    func blockUserReport(userID: String) {
        var BUser = BlockUserObj(KIND: .IBlocked, UID: userID)
        BLOCKUSERIDLISTARRAY.append(BUser)
    }
}


///EXTENSION[各種機能群]
extension showUserListViewController {
    
    ///初期リロード（ベーシック）
    func basicReloadData() {
        ///クエリ設定呼び出し
        querySetting()
        ///ユーザー一覧格納配列初期化
        self.USERSPROFILEARRAY = []
        self.CHATUSERLISTTABLEVIEW.reloadData()
        ///スクロールカウンターは1に戻す
        self.QUERY.scrollCounter = 1
        ///スクロール時のサーバーアクセス停止フラグを許可
        self.scrollServerAccessPermFlag = true
        ///サーバーアクセス
        self.userDataServerGetting(filter: self.QUERY)
    }
    
    /// 最下層に来た際のインジケータ表示
    /// - Parameter showing: 表示するか否か
    func ActivityIndicatorShow(showing:Bool) {
        ///インジケータのY軸
        let indicatorY = self.CHATUSERLISTTABLEVIEW.contentSize.height + 25
        
        if showing {
            ///下方向の余白を設定
            self.CHATUSERLISTTABLEVIEW.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)

            self.CHATUSERLISTTABLEVIEW.addSubview(activityIndicatorView)
            ///余白領域の中央にインジケータ配置
            activityIndicatorView.center = CGPoint(x: self.CHATUSERLISTTABLEVIEW.bounds.midX, y: indicatorY)
            self.CHATUSERLISTTABLEVIEW.layoutIfNeeded()
            activityIndicatorView.startAnimating()
        } else {
            self.CHATUSERLISTTABLEVIEW.contentInset = defaultInsets // 余白をリセット
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            self.CHATUSERLISTTABLEVIEW.layoutIfNeeded()
        }
    }


    /// ローカルに保存してあるApiKeyとそのバージョンを取得。存在していない場合はバックエンドサーバーから取得
    /// - Parameter callback: apikey = APIキー　,version = バージョン
    func ApiKeyGetter(callback: @escaping (String,String,String) -> Void) {
        ///ローカルからAPIKEYを取得
        if let APIKEYOBJECT = APIKEYLOCALGETTER.getter() {
            callback(APIKEYOBJECT.appID!,APIKEYOBJECT.APIKey!,APIKEYOBJECT.version!)
            return
        }
        ///ローカルに存在しない場合はバックエンドサーバーから取得
        searchAPIKeySingleton().generateSecuredApiKey { apikey,appID,version in
            if apikey == "ERROR" {
                createSheet(for: .Alert(title: "初期設定に失敗しました。エラーCODE301", message: "運営にお問い合わせください。アプリを終了します", buttonMessage: "OK", { result in
                    preconditionFailure("")
                }), SelfViewController: self)
            }
            ///ローカルに保存
            self.apiKeyLocalSave(APIKEY: apikey, appID: appID, VERSION: version)
            ///返却
            callback(appID,apikey,version)
            return
        }
    }
    
    ///APIKEYのローカル保存
    /// - Parameters:
    ///   - APIKEY: 保存するAPIKey
    ///   - appID: 保存するappID
    ///   - VERSION: バージョン指定
    func apiKeyLocalSave(APIKEY:String,appID:String,VERSION:String) {
        ///保存用のアンマネージドオブジェクト
        let newAPIKey = ApiKeyLocalObject()
        newAPIKey.APIKey = APIKEY
        newAPIKey.version = VERSION
        newAPIKey.appID = appID
        ///セッターマネージャをインスタンス化してコミット準備
        var APIKEYSETTER = ApiKeyDataLocalSetterManager(newAddApiKey: newAPIKey)
        ///コミット
        APIKEYSETTER.commiting = true
    }
    
    /// 不正エラー検出時処理
    func invalidUserCompletion() {
        createSheet(for: .Completion(title: "不正なユーザーの可能性があるため強制終了します。再登録してください。", {
            preconditionFailure()
        }), SelfViewController: self)
    }
}

//検索画面からのDelegate
extension showUserListViewController:SearchSettingViewControllerBackActionDelegate{
    ///検索画面から戻ってきたらユーザーリロード
    func searchViewBackAction() {
        basicReloadData()
    }
}


//ターゲットのプロフィール画面からのデリゲート
extension showUserListViewController:TargetProfileLikeButtonTappedDelegate {
    func likeButtonPushListControllerDelegate() {
        selectingCell.likePush = true
        USERSPROFILEARRAY.first(where: {$0.Required_UID == selectingCell.celluserStruct.Required_UID})?.Required_LikeButtonPushedFLAG = true
    }
}
