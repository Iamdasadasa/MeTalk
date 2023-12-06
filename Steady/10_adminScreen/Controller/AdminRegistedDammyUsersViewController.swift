//
//  showUserListVoewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/11/09.
//

import Foundation
import UIKit
import Firebase
import RealmSwift
import CoreAudio
//ユーザー一覧画面
class AdminRegstedDammyUsersViewController:UIViewController,UINavigationControllerDelegate, UserListTableViewCellDelegate{

    
    //++変数宣言　クロージャー++//
    let CHATUSERLISTTABLEVIEW = UITableView()   ///Viewのインスタンス化
    let SEARCHVIEWCONTROLLER = SearchSettingViewController()    ///検索画面インスタンス化
    let TALKLISTDATAHOSTGETTER = TalkListGetterManager()    ///トークリストのユーザーを取得するインスタンス(FIREBASE)
    let CONTENTSHOSTINGGETTER = ContentsHostGetter()    ///画像データを取得するインスタンス(FIREBASE)
    let PERFORMSEARCHLOCALGETTER = PerformSearchLocalDataGetterManager()
    let ADMINDATAGETTER = adminHostGetterManager()
    ///検索条件を管理するインスタンス
    var USERSPROFILEARRAY:[RequiredProfileInfoLocalData] = []  ///ユーザー一覧格納配列
    var SELFINFO:RequiredProfileInfoLocalData ///自身の情報
    let tabBarHeight:CGFloat    ///タブバーの高さ
    let defaultInsets:UIEdgeInsets  ///表示位置の基準
    var isReadyToLoadPosition:Bool = false  ///スクロール完全停止フラグ
    var scrollServerAccessPermFlag:Bool = true  ///サーバーアクセス停止フラグ
    let cache = NSCache<NSString, UIImage>()    ///画像データ用のキャッシュ
    var reloading = true {   ///ユーザーローディングフラグ
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
        ///ナビゲーションバーセットアップ
        navigationBarSetUp()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
//EXTENSION[UITableView関連]
extension AdminRegstedDammyUsersViewController:UITableViewDelegate, UITableViewDataSource{

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
        cell.LikeButton.isEnabled = false
        ///セルのデリゲート設定
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as? UserListTableViewCell
        let imageObj = listUsersImageLocalObject()
        imageObj.profileImage = selectedCell?.profileImageView.image ?? UIImage(named: "defProfile")!
        //ダミーユーザーのチャット一覧に遷移
        let dammyUsersCV = TargetChatUserListViewController(tabBarHeight: 0.0, SELFINFO:USERSPROFILEARRAY[indexPath.row], SELFIMAGEOBJECT:imageObj, dammyUserListFlag: true)
         self.navigationController?.pushViewController(dammyUsersCV, animated: true)
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

                // デリゲートは何回も呼ばれてしまうので、リロード中はfalseにしておく
                self.reloading = false
                ///ユーザー情報取得
                self.userDataServerGetting()
            }
        }
    }
}

///EXTENSION[ネットワーク通信関連]
extension AdminRegstedDammyUsersViewController {
    
    /// ユーザー一覧をサーバーから取得
    /// - Parameter filter: 検索条件
    func userDataServerGetting() {
        ADMINDATAGETTER.dammyUsersListDataGetter(callback: { usersList, err in
            ///サーバーからの取得件数が0
            if usersList.count == 0{
                self.reloading = true
                self.scrollServerAccessPermFlag = false
                return
            }
            ///一件ずつ処理
            for data in usersList{
                if let RequiredProfile = self.CheckingDataAndlikeDataExtra(PROFILE: data){

                    ///トークリスト配列に追加
                    self.USERSPROFILEARRAY.append(RequiredProfile)
                }
            }
            self.reloading = true
            self.CHATUSERLISTTABLEVIEW.reloadData()
        })
        
    }
    
    /// ライクデータをホスティングで取得してきたデータに付与
    /// - Parameter PROFILE: ホスティングで取得したデータ

    func CheckingDataAndlikeDataExtra(PROFILE:ProfileInfoLocalObject) -> RequiredProfileInfoLocalData? {
        /// データ不備が一つでもあれば追加しない
        guard let UID = PROFILE.lcl_UID,let DateCreatedAt = PROFILE.lcl_DateCreatedAt,let DateUpdatedAt = PROFILE.lcl_DateUpdatedAt,let AboutMeMassage = PROFILE.lcl_AboutMeMassage,let NickName = PROFILE.lcl_NickName,let Area = PROFILE.lcl_Area else {
            return nil
        }
        ///安全なデータとして格納
        let RequiredProfile = RequiredProfileInfoLocalData(UID: UID, DateCreatedAt: DateCreatedAt, DateUpdatedAt: DateUpdatedAt, Sex: PROFILE.lcl_Sex, AboutMeMassage: AboutMeMassage, NickName: NickName, Age: PROFILE.lcl_Age, Area: Area)
        
        return RequiredProfile
    }
    
}
///EXTENSION[NavigationBar関連]
extension AdminRegstedDammyUsersViewController {
    /// ナビゲーションバー初期セットアップ
    func navigationBarSetUp() {
        /// カスタムのタイトルビューを作成
        let titleLabel = UILabel()
        titleLabel.text = "ダミーユーザー一覧"
        titleLabel.textColor = UIColor.black
        /// ナビゲーションバーのタイトルビューを設定
        self.navigationItem.titleView = titleLabel
        ///リロードボタン設定
        let reloadButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadButtonTapped))
        ///リロードボタンセット
        navigationItem.rightBarButtonItem = reloadButton

    }
    ///リロードボタンタップ時のアクション
    @objc func reloadButtonTapped() {
        // データリロード
        basicReloadData()
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


///EXTENSION[各種機能群]
extension AdminRegstedDammyUsersViewController {
    
    ///初期リロード（ベーシック）
    func basicReloadData() {
        ///ユーザー一覧格納配列初期化
        self.USERSPROFILEARRAY = []
        self.CHATUSERLISTTABLEVIEW.reloadData()
        ///スクロール時のサーバーアクセス停止フラグを許可
        self.scrollServerAccessPermFlag = true
        ///サーバーアクセス
        self.userDataServerGetting()
    }
    
    /// 最下層に来た際のインジケータ表示
    /// - Parameter showing: 表示するか否か
    func ActivityIndicatorShow(showing:Bool) {
        ///インジケータのY軸
        let indicatorY = self.CHATUSERLISTTABLEVIEW.contentSize.height + 25
        
        if showing {
            ///下方向の余白を設定
            self.CHATUSERLISTTABLEVIEW.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        } else {
            self.CHATUSERLISTTABLEVIEW.contentInset = defaultInsets // 余白をリセット
            self.CHATUSERLISTTABLEVIEW.layoutIfNeeded()
        }
    }
    
    func likebuttonPushed(CELL: UserListTableViewCell, CELLUSERSTRUCT: RequiredProfileInfoLocalData) {
        return
    }
    
    func profileImageButtonPushed(CELL: UserListTableViewCell, CELLUSERSTRUCT: RequiredProfileInfoLocalData) {
        return
    }
}
