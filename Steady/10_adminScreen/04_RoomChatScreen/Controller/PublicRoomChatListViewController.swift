//
//  ChatUserListViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/12/18.
//

import Foundation
import UIKit
import Firebase
import RealmSwift
import GoogleMobileAds
import AudioToolbox

protocol PublicRoomChatListViewControllerDelegate:AnyObject {
    func PublicRoomAlreadyEnterdNortification()
}

//チャット一覧画面
class PublicRoomChatListViewController:UIViewController,UINavigationControllerDelegate{
    //++変数宣言　クロージャー++//
    let PUBLICROOMLISTTABLEVIEW = UITableView() ///テーブルビューのインスタンス化
    var SELFINFO:RequiredProfileInfoLocalData ///自身の情報
    let PublicRoomInfoGetting = PublicRoomChatDataHostGetter()
    let PublicRoomInfoSetting = PublicRoomChatDataHostSetter()
    var CONTENTSHOSTINGGETTER = ContentsHostGetter()
    let CONTENTSLOCALGETTER = ImageDataLocalGetterManager()
    let PLOFILEHOSTGETTER = ProfileHostGetter()
    var PUBLICROOMARRAY:[RequiredPublicRoomInfoStruct] = []
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
    weak var delegate:PublicRoomChatListViewControllerDelegate?
    
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
        super.viewDidLoad()
        ///コンテナビュー他View等の設定
        containerViewSetUp()
        ///標準セットアップ
        setUp()
        ///ナビゲーションバーセットアップ
        navigationBarSetUp()
        PublicRoomDataGetting()
    }
    
    func setUp() {
        ///テーブルビューレイアウト
        PUBLICROOMLISTTABLEVIEW.backgroundColor = .white
        PUBLICROOMLISTTABLEVIEW.contentInset = defaultInsets
        PUBLICROOMLISTTABLEVIEW.scrollIndicatorInsets = defaultInsets
        ///テーブルビューのデリゲート処理
        PUBLICROOMLISTTABLEVIEW.dataSource = self
        PUBLICROOMLISTTABLEVIEW.delegate = self

        ///セルの登録
        PUBLICROOMLISTTABLEVIEW.register(PublicRoomChatListTableViewCell.self, forCellReuseIdentifier: "PublicRoomChatListTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ///広告表示
        mobAdsViewSetting()
    }
}

//EXTENSION[UITableView関連]
extension PublicRoomChatListViewController:UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PUBLICROOMARRAY.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ///cellのインデックス番号の箇所のユーザー情報格納
        let PUBLICROOMINFO = PUBLICROOMARRAY[indexPath.row]
        ///セルのインスタンス化
        let cell = tableView.dequeueReusableCell(withIdentifier: "PublicRoomChatListTableViewCell", for: indexPath ) as! PublicRoomChatListTableViewCell
        
        ///セルの選択状態の不可
        cell.selectionStyle = .none
        
        guard let RoomTypeInfo = PUBLICROOMINFO.roomTypeInfo else {
            createSheet(for: .Alert(title: "不正なルームの検出", message: "運営に問い合わせてください", buttonMessage: "OK", { _ in
                return
            }), SelfViewController: self)
            return cell
        }
        cell.cellHavingRoomType = PUBLICROOMINFO.roomTypeInfo
        cell.roomImageViewSetCell(Image: RoomTypeInfo.RoomImage)
        cell.flowRoomNameTextSetCell(text: PUBLICROOMINFO.name)
        cell.roomInfoCapacityTextSetCell(text: "\(PUBLICROOMINFO.currentParticipants)/\(PUBLICROOMINFO.maxParticipants)")
        if PUBLICROOMINFO.isFull {
            cell.roomInfoAvailabilityTextSetCell(text: "満室")
        } else {
            cell.roomInfoAvailabilityTextSetCell(text: "空室")
        }
        cell.AvailabilityImageSetCell(Image: PUBLICROOMINFO.RoomAvailabilityImage)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ///タップしたセルのルーム情報を取得
        let PUBLICROOMINFO = PUBLICROOMARRAY[indexPath.row]
        if PUBLICROOMINFO.isFull {
            createSheet(for: .Retry(title: "ルームが満員です。"), SelfViewController: self)
            return
        }
        /// 選択された行のセルを一時的に取得
        guard let cell = tableView.cellForRow(at: indexPath) as? PublicRoomChatListTableViewCell else {
            createSheet(for: .Retry(title: "ルーム情報を取得できませんでした"), SelfViewController: self)
            return
        }
        
        let cellHavingRoomType:RoomInfoCommonImmutable = cell.cellHavingRoomType
        
        var gender: GENDER{
            get {
                GENDER(rawValue: SELFINFO.Required_Sex)!
            }
        }

        PublicRoomInfoSetting.updateEnterRoom(callback: { errorReason in
            ///入手不可変数が存在したら警告してリターン
            if let errorDescription = errorReason {
                createSheet(for: .Completion(title: errorDescription.errorDescription, {
                    return
                }), SelfViewController: self)
                return
            }
            ///遷移
            let chatViewController = PublicRoomChatViewController(selfProfile: self.SELFINFO, SELFPROFILEIMAGE: self.SELFIMAGEOBJECT.profileImage, selectedRoom:cellHavingRoomType)
            ///自身を遷移先の画面に適用
            chatViewController.PUBLICROOMCHATLISTVIEWCONTROLLER = self
            let UINavigationController = UINavigationController(rootViewController: chatViewController)
            UINavigationController.modalPresentationStyle = .fullScreen
            self.present(UINavigationController, animated: false, completion: nil)
            self.slideInFromRight() // 遷移先の画面を横スライドで表示
            
        }, gender: gender, UID: SELFINFO.Required_UID, RoomInfo: PUBLICROOMINFO)
        
    }
    
}

///EXTENSION[ネットワーク通信関連]
extension PublicRoomChatListViewController {
    func PublicRoomDataGetting() {
        PublicRoomInfoGetting.AllRoomParticipants(callback: { hostingPublicRoomInfo,alredyEnterd  in
            ///ルーム情報配列初期化
            self.PUBLICROOMARRAY = []
            ///各ルーム情報の適用
            for data in hostingPublicRoomInfo {
                self.PUBLICROOMARRAY.append(data)
            }
            self.PUBLICROOMLISTTABLEVIEW.reloadData()
            
            //自身が退出済みになった場合
            if let _ = alredyEnterd  {} else {
                //デリゲートを通じてパブリックチャットルームに通知
                self.delegate?.PublicRoomAlreadyEnterdNortification()
            }
        }, UID: SELFINFO.Required_UID)
    }

}

///EXTENSION[NavigationBar関連]
extension PublicRoomChatListViewController {
    /// ナビゲーションバー初期セットアップ
    func navigationBarSetUp() {
        /// カスタムのタイトルビューを作成
        let titleLabel = UILabel()
        titleLabel.text = "チャットルーム"
        titleLabel.textColor = UIColor.gray
        /// ナビゲーションバーのタイトルビューを設定
        self.navigationItem.titleView = titleLabel
        navigationController?.navigationBar.barTintColor = UIColor.white
    }
}
///その他の処理
extension PublicRoomChatListViewController {
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
        containerView.addSubview(PUBLICROOMLISTTABLEVIEW) ///追記
        ///テーブルビューもレイアウトを合わせておく
        PUBLICROOMLISTTABLEVIEW.translatesAutoresizingMaskIntoConstraints = false
        PUBLICROOMLISTTABLEVIEW.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        PUBLICROOMLISTTABLEVIEW.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        PUBLICROOMLISTTABLEVIEW.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        PUBLICROOMLISTTABLEVIEW.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    //
}

///広告の実装
extension PublicRoomChatListViewController {
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
