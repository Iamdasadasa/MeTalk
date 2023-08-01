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

class showUserListViewController:UIViewController,UINavigationControllerDelegate{
    ///インスタンス化(View)
    let CHATUSERLISTTABLEVIEW = UITableView()
    ///UIDインスタンス
    private var MYUID:String!
    private var MYPROFILE:ProfileInfoLocalObject!
    ///データ処理関連
    let TALKDATASETTER:TalkListSetterManager = TalkListSetterManager()
    let TALKDATAGETTER:TalkListGetterManager = TalkListGetterManager()
    let CONTENTSHOSTING:ContentsGetterManager = ContentsGetterManager()
    let LOCALPERFORMSEARCH:PerformSearchLocalDataGetterManager = PerformSearchLocalDataGetterManager()
    var QUERY:QueryFilter = QueryFilter(minAge: nil, maxAge: nil, gender: nil, area: nil)
    ///情報格納用変数
    var LOCALUSERSPROFILEARRAY:[RequiredProfileInfoLocalData] = []
    var ImageDataArray:[ImageDataHolder] = []
    ///相手との一意ID作成インスタンス
    let ROOMID = chatTools()
    ///タブバーの高さ
    let tabBarHeight:CGFloat
    let defaultInsets:UIEdgeInsets
    ///インジケータロードビュー
    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    ///画面ロードビュー
    let loading = LOADING(loadingView: LoadingView(), BackClear: true)
    ///スクロールでロードした際のカウンター
    var scrollExtraUserCounter:Int = 0
    ///スクロール完全停止フラグ
    var isReadyToLoadPosition:Bool = false
    ///画像データ用のキャッシュ
    let cache = NSCache<NSString, UIImage>()
    
    
    ///ここから⭐️
    var visibleItemCount:Int {
        get {
            return self.QUERY.fixCount * self.QUERY.scrollCounter
        }
    }
    
    ///件数オーバーOr件数が少ない際のチェック
    enum OverOrLack {
        case Over
        case Lack
    }
    var gettingUserCountChecker:OverOrLack? {
        willSet {
            ///件数オーバー
            if newValue == .Over {
                ///差分
                let countToRemove = self.scrollExtraUserCounter - (self.QUERY.fixCount * self.QUERY.scrollCounter)
                ///配列の下から差分の数を削除
                self.LOCALUSERSPROFILEARRAY = self.LOCALUSERSPROFILEARRAY.dropLast(countToRemove)
            } else {
            ///件数が足りない
                ///件数倍数を追加して再度呼び出す
                self.QUERY.scrollCounter = self.QUERY.scrollCounter + 1
                userDataServerGetting(filter: QUERY)
            }
        }
    }
    
    ///ここまで⭐️



    ///ユーザーローディングフラグ
    var reloading = true {
        ///ロードインジケータ表示可否
        willSet {
            if newValue {
                ///インジケータ非表示
                ActivityIndicatorShow(showing: false)
            } else {
                ///インジケータ表示
                ActivityIndicatorShow(showing: true)
            }
        }
    }
    
    init(tabBarHeight:CGFloat) {
        self.tabBarHeight = tabBarHeight
        self.defaultInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight, right: 0)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ///ローカルから検索条件を取得してクエリ変数に適用
        let queVal = LOCALPERFORMSEARCH.getter()
        ///年齢
        QUERY.minAge = queVal?.lcl_MinAge
        QUERY.maxAge = queVal?.lcl_MaxAge
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
            QUERY.gender = queVal?.lcl_Gender
        }

        ///自身のプロフィールをあらかじめ取得
        let profileGetter = TargetProfileGetterManager()
        ///自身のUIDを取得
        self.MYUID = myProfileSingleton.shared.selfUIDGetter(UIViewController: self)
        profileGetter.getter(callback: { SelfProfile, Err in
            ///自身のデータがサーバー登録にない場合ログアウトして強制終了
            if Err != nil {
                self.err(Type: .InvalidSelfData)
            }
            ///グローバルな変数に自身のプロフィールを格納
            self.MYPROFILE = SelfProfile
            // データリロード
            self.basicReloadData()
        }, UID: MYUID)

    }
    
}
///EXTENSION[UITableView関連]
extension showUserListViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LOCALUSERSPROFILEARRAY.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ///セルのインスタンス化
        var cell = tableView.dequeueReusableCell(withIdentifier: "UserListTableViewCell", for: indexPath ) as! UserListTableViewCell
        
        ///cellのインデックス番号の箇所のユーザー情報格納
        let PROFILEINFOLOCAL = LOCALUSERSPROFILEARRAY[indexPath.row]

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
            self.CONTENTSHOSTING.ImageDataGetter(callback: { Image, err in
                ///セルに設定
                cell.profileImageView.image = Image.profileImage
                ///キャッシュに保存
                self.cache.setObject(Image.profileImage, forKey: cacheID)
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
            if self.reloading {
                ///スクロールカウンターを追加
                self.QUERY.scrollCounter = self.QUERY.scrollCounter + 1
                ///追加できたユーザーのカウンター初期化
                scrollExtraUserCounter = 0
                // デリゲートは何回も呼ばれてしまうので、リロード中はfalseにしておく
                self.reloading = false

                ///ユーザー情報取得
                self.userDataServerGetting(filter: self.QUERY)
            }
        }
    }
}
///EXTENSION[画面上のボタンを押下時のアクション関連]
extension showUserListViewController:UserListTableViewCellDelegate {
    
    /// 画面上のライクボタンを押下した際の処理
    /// - Parameters:
    ///   - CELL: 対象のセルそのもの
    ///   - CELLUSERSTRUCT: 対象のセルに格納されているプロフィールデータ
    func likebuttonPushed(CELL: UserListTableViewCell, CELLUSERSTRUCT: RequiredProfileInfoLocalData) {
        CELL.likeAnimationPlay(targetImageView: CELL.ImageView)
        ///アニメーション中に連続押下防止
        CELL.LikeButton.isEnabled = false
        ///ライクデータ更新
        LikeButtonPushedInfoUpdate(CELL: CELL)
        ///セル再利用時に正しい押下データになるようデータ格納
        guard let ArrayInTargetProfile = self.LOCALUSERSPROFILEARRAY.first(where: {$0.Required_UID == CELLUSERSTRUCT.Required_UID}) else {
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
        ///セルのユーザー情報
        guard let targetProfile = CELL.celluserStruct else {
            err(Type: .likeButtonInvalid)
            return
        }
        
        ///相手とのルームIDを作成
        let roomID = ROOMID.roomIDCreate(UID1: MYUID, UID2: targetProfile.Required_UID)
        ///ローカルトークデータ処理
        localTalkDataCreateAndRegister(ROOMID: roomID)
        ///ローカルプロファイルデータ処理
        hostAndlocalProfileDataCreateAndRegister(roomID: roomID, CELL: CELL)
    }
}
///EXTENSION[ユーザーデータ取得関連]
extension showUserListViewController {
    enum ErrType{
        case InvalidSelfData
        case targetDataFailedData
        case likeButtonInvalid
    }
    
    func err(Type:ErrType) {
        switch Type {
        case .InvalidSelfData:
            createSheet(callback: {
                do {
                    try Auth.auth().signOut()
                } catch let signOutError as NSError {
                    print("SignOut Error: %@", signOutError)
                }
                preconditionFailure("強制退会")
            }, for: .Retry(title: "あなたのデータは不正です。再度登録を行なってください。アプリを終了します。"), SelfViewController: self)
        case .targetDataFailedData:
            createSheet(callback: {
                return
            }, for: .Retry(title: "ユーザーの取得に失敗しました。もう一度お試しください"), SelfViewController: self)
        case .likeButtonInvalid:
            createSheet(callback: {
                return
            }, for: .Retry(title: "相手にライクを送れせんでした。もう一度お試しください"), SelfViewController: self)
        }
    }
    
    func userDataServerGetting(filter:QueryFilter) {
        TALKDATAGETTER.onlineUsersDataGetter(callback: { gettingData, Err in
            ///エラー時の処理
            if let Err = Err{
                self.err(Type: .targetDataFailedData)
                return
            }
            ///サーバーからの取得件数が0
            if gettingData.count == 0{
                self.reloading = true
                return
            }
            ///一件ずつ処理
            for data in gettingData {
                if let RequiredProfile = self.CheckingDataAndlikeDataExtra(PROFILE: data){
                    self.scrollExtraUserCounter += 1
                    ///トークリスト配列に追加
                    self.LOCALUSERSPROFILEARRAY.append(RequiredProfile)
                }
            }
            ///サーバーから取得したユーザー数が指定した件数を取れずに頭打ちしていない場合
            if self.visibleItemCount < gettingData.count {
                ///件数調整(スクロールで追加したユーザーが固定の追加数を超えたら)
                if self.scrollExtraUserCounter > self.QUERY.fixCount {
                    self.gettingUserCountChecker = .Over
                }
                
                ///配列の件数が最低表示件数に満たない場合のチェック
                if self.LOCALUSERSPROFILEARRAY.count < (self.QUERY.fixCount * self.QUERY.scrollCounter) {
                    self.gettingUserCountChecker = .Lack
                }
            }
            ///最後に更新時間順にソート
            self.LOCALUSERSPROFILEARRAY.sort(by: {$0.Required_DateUpdatedAt > $1.Required_DateUpdatedAt})
            
            self.reloading = true
            self.CHATUSERLISTTABLEVIEW.reloadData()
        }, filter: filter)
    }
    
    /// ライクデータをホスティングで取得してきたデータに付与
    /// - Parameter PROFILE: ホスティングで取得したデータ
    /// - Returns: ローカルに保存してあるライクデータを付与して返却
    func CheckingDataAndlikeDataExtra(PROFILE:ProfileInfoLocalObject) -> RequiredProfileInfoLocalData? {
        /// データ不備が一つでもあれば追加しない
        guard let UID = PROFILE.lcl_UID,let DateCreatedAt = PROFILE.lcl_DateCreatedAt,let DateUpdatedAt = PROFILE.lcl_DateUpdatedAt,let AboutMeMassage = PROFILE.lcl_AboutMeMassage,let NickName = PROFILE.lcl_NickName,let Area = PROFILE.lcl_Area else {
            return nil
        }
        ///既にトーク配列に存在していたら追加しない
        if  self.LOCALUSERSPROFILEARRAY.first(where: {$0.Required_UID == UID}) != nil {
            return nil
        }
        
        let RequiredProfile = RequiredProfileInfoLocalData(UID: UID, DateCreatedAt: DateCreatedAt, DateUpdatedAt: DateUpdatedAt, Sex: PROFILE.lcl_Sex, AboutMeMassage: AboutMeMassage, NickName: NickName, Age: PROFILE.lcl_Age, Area: Area)
        
        ///ローカルからライク押下データのみを最新データに反映
        let LOCALTALKDATAGETTER = TargetProfileLocalDataGetterManager(targetUID: PROFILE.lcl_UID!)
        let localTargetProfile = LOCALTALKDATAGETTER.getter()
        ///ライク押下データ処理
        if let pushDate = localTargetProfile?.lcl_LikeButtonPushedDate{
            RequiredProfile.Required_LikeButtonPushedDate = pushDate
            RequiredProfile.Required_LikeButtonPushedFLAG = self.pushTimeDiffDate(pushTime: pushDate)
            ///付与して返却
            return RequiredProfile
        } else {
            ///押下データがない場合は付与せず返却
            RequiredProfile.Required_LikeButtonPushedFLAG = false
            return RequiredProfile
        }
    }
    
    /// ローカルトークデータ用の構造体を作成して登録する処理-ここではライクボタンを押下した情報-
    /// - Parameter ROOMID: 一意となるトーク対象と自分のID
    func localTalkDataCreateAndRegister(ROOMID:String) {
        let likeMessage = MessageLocalObject()
        //トークデータローカル保存
        likeMessage.lcl_RoomID = ROOMID
        likeMessage.lcl_MessageID = UUID().uuidString
        likeMessage.lcl_Listend = true
        likeMessage.lcl_Date = Date()
        likeMessage.lcl_Sender = self.MYUID
        likeMessage.lcl_LikeButtonFLAG = true
        likeMessage.lcl_Message = ""
        ///作成もしくは更新処理
        var LocalUpdateObject = MessageLocalSetterManager(updateMessage: likeMessage)
        ///コミット
        LocalUpdateObject.commiting = true
    }
    
    /// ライクボタンを押した相手の情報をローカルとサーバーに登録
    /// - Parameters:
    ///   - roomID: 一意となるトーク対象と自分のID
    ///   - targetUID: 相手のUID
    func hostAndlocalProfileDataCreateAndRegister(roomID:String,CELL:UserListTableViewCell) {
        ///セルのユーザー情報
        guard let targetProfile = CELL.celluserStruct else {
            err(Type: .likeButtonInvalid)
            return
        }
        ///Update用新規アンマネージドオブジェクト
        var UpdateProfile = ProfileInfoLocalObject()
        ///すべての処理が終了するまでロードインジケータ表示
        loading.loadingViewIndicator(isVisible: true)
        ///アンマネージドオブジェクトの更新対象以外をマッピング
        UpdateProfile = updateObjectMapping(unManagedObject: UpdateProfile, managedObject: targetProfile)
        UpdateProfile.lcl_LikeButtonPushedFLAG = true
        UpdateProfile.lcl_LikeButtonPushedDate = Date()
        ///ローカル保存開始
        var profileDataSetter = TargetProfileLocalDataSetterManager(updateProfile: UpdateProfile)
        ///サーバ処理失敗時のクロージャ
        let failedToRetry = {
            self.err(Type: .likeButtonInvalid)
            CELL.likePush = false
            profileDataSetter.commiting = false
        }
        ///トークデータの複数回コールバックカウント
        var callbackCount = 0
        ///サーバー保存
        ///それぞれのトーク情報にライクボタン情報を送信
        self.TALKDATASETTER.likePushingChatDataSetter(
            callback:{hostingresult in
                ///チャット失敗
                guard hostingresult else {
                    failedToRetry()
                    ///ロードインジケータ非表示
                    self.loading.loadingViewIndicator(isVisible: false)
                    return
                }
                ///それぞれのトークリストを更新
                self.TALKDATASETTER.talkListToUserInfoSetter(
                    callback: {hostingresult in
                        callbackCount += 1
                        ///トークリスト更新失敗
                        guard hostingresult else {
                            failedToRetry()
                            ///ロードインジケータ非表示
                            self.loading.loadingViewIndicator(isVisible: false)
                            return
                        }
                        ///自分と相手も問題なく登録できたら
                        if callbackCount == 2 {
                            ///トランザクション中のローカルデータもコミット
                            profileDataSetter.commiting = true
                            ///ロードインジケータ非表示
                            self.loading.loadingViewIndicator(isVisible: false)
                        }

                    }, UID1: self.MYUID,UID2: targetProfile.Required_UID,message: "",
                    sender: self.MYUID,nickName1: self.MYPROFILE.lcl_NickName!,
                    nickName2: targetProfile.Required_NickName,like: true,blocked: false
                )
            ///
            }, message: "",messageId: UUID().uuidString,sender: self.MYUID,
            Date: Date(),roomID: roomID,TargetUID: targetProfile.Required_UID)
    }
}
///EXTENSION[NavigationBar関連]
extension showUserListViewController {
    /// ナビゲーションバー初期セットアップ
    func navigationBarSetUp() {
        /// カスタムのタイトルビューを作成
        let titleLabel = UILabel()
        titleLabel.text = "コミュニケーション"
        titleLabel.textColor = UIColor.black
        /// ナビゲーションバーのタイトルビューを設定
        self.navigationItem.titleView = titleLabel
        ///リロードボタン設定
        let reloadButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadButtonTapped))
        ///リロードボタンセット
        navigationItem.rightBarButtonItem = reloadButton
        ///検索ボタン設定
        let filterButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterButtonTapped))
        ///検索ボタンセット
        navigationItem.leftBarButtonItem = filterButton

    }
    ///リロードボタンタップ時のアクション
    @objc func reloadButtonTapped() {
        // データリロード
        basicReloadData()
    }
    
    ///検索ボタンタップ時のアクション
    @objc func filterButtonTapped() {
        let searchViewController = SearchSettingViewController()
        let UINavigationController = UINavigationController(rootViewController: searchViewController)
        UINavigationController.modalPresentationStyle = .fullScreen
        self.present(UINavigationController, animated: false, completion: nil)
        self.slideOutToLeft() // 遷移先の画面を横スライドで表示
    }
    
    // 引っ張り操作でのリフレッシュ処理
    @objc func refreshData() {
        // データリロード
        basicReloadData()
        // リフレッシュコントロールの終了処理
        CHATUSERLISTTABLEVIEW.refreshControl?.endRefreshing()
    }
}

///EXTENSION[各種機能群]
extension showUserListViewController {
    
    ///初期リロード（ベーシック）
    func basicReloadData() {
        ///ユーザー一覧格納配列初期化
        self.LOCALUSERSPROFILEARRAY = []
        self.CHATUSERLISTTABLEVIEW.reloadData()
        reloading = false
        ///スクロール時のユーザー追加カウンターは0に戻す
        self.scrollExtraUserCounter = 0
        ///スクロールカウンターは1に戻す
        self.QUERY.scrollCounter = 1
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
    
    /// ローカルデータ更新時のUpdate用オブジェクトに既存オブジェクトをマッピング
    /// - Parameters:
    ///   - unManagedObject: Realmに保村されていないアンマネージドオブジェクト
    ///   - managedObject: Realmに保存済みのマネージドオブジェクト
    /// - Returns: トランザクションに影響しない更新対象となるアンマネージドオブジェクト
    func updateObjectMapping(unManagedObject:ProfileInfoLocalObject,managedObject:RequiredProfileInfoLocalData)-> ProfileInfoLocalObject{
        unManagedObject.lcl_UID = managedObject.Required_UID
        unManagedObject.lcl_DateCreatedAt = managedObject.Required_DateCreatedAt
        unManagedObject.lcl_DateUpdatedAt = managedObject.Required_DateUpdatedAt
        unManagedObject.lcl_Sex = managedObject.Required_Sex
        unManagedObject.lcl_AboutMeMassage = managedObject.Required_AboutMeMassage
        unManagedObject.lcl_NickName = managedObject.Required_NickName
        unManagedObject.lcl_Age = managedObject.Required_Age
        unManagedObject.lcl_Area = managedObject.Required_Area
        
        return unManagedObject
    }
    
    /// 指定された時間より60分経ってるか
    /// - Parameter pushTime: 指定時間
    /// - Returns: 経っている場合か否かのBool値
    func pushTimeDiffDate(pushTime: Date) -> Bool {
        let minute = round(Date().timeIntervalSince(pushTime) / 60)
        return minute <= 0.01
    }
}

