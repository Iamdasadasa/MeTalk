//
//  Me2TalkUserListViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/02.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import Photos
import FloatingPanel
import CropViewController
import SideMenu
import RealmSwift
import GoogleMobileAds

protocol ProfileViewControllerDelegate:AnyObject {
    func blockUserReport(userID:String)
}

class ProfileViewController:UIViewController, CropViewControllerDelegate{
    //++変数宣言　クロージャー++//
    var loadViewvisible:Bool = false {  ///ロードビュー表示有無
        willSet {
            if newValue {
                self.loadingView.loadingViewIndicator(isVisible: true)
            } else {
                self.loadingView.loadingViewIndicator(isVisible: false)
            }
        }
    }
    var realm:Realm = { ///暗号化したRealmを生成
        let Database = acquireRealmDatabase()
        return Database.gettingDataBase()
    }()
    var TARGETINFO:RequiredProfileInfoLocalData ///このViewで扱うユーザーの情報
    var SELFINFO:RequiredProfileInfoLocalData ///自身の情報
    var handle:AuthStateDidChangeListenerHandle?    ///認証状態のリッスン変数
    let PICKER = UIImagePickerController()    ///カメラピッカー
    var SIDEMENUVIEWCONTROLLER:SideMenuViewcontroller {  ///サイドメニュービュー
        get {
            let SIDEMENUVIEWCONTROLLER = SideMenuViewcontroller(SELFINFO: SELFINFO)
            SIDEMENUVIEWCONTROLLER.delegate = self
            return SIDEMENUVIEWCONTROLLER
        }
    }
        
    let SHOWIMAGEVIEWCONTROLLER = ShowImageViewController()    ///画像表示ビュー
    let PROFILEVIEW = ProfileView() ///プロフィールビュー
    let CONTENTSHOSTSETTER = ContentsHostSetter()   ///画像データを保存するインスタンス(Firebase)
    let CONTETNSHOSTGETTER = ContentsHostGetter()
    let IMAGELOCALGETTER = ImageDataLocalGetterManager()    ///画像データを取得するインスタンス(Realm)
    let LISTDATAHOSTINGSETTER = ListDataHostSetter()    ///トークリストのユーザーを保存するインスタンス(FIREBASE)
    let CHATDATAHOSTSETTER = ChatDataHostSetterManager()    ///チャットデータを保存するインスタンス(FIREBASE)
    let PLOFILEHOSTGETTER = ProfileHostGetter() ///プロフィール情報を取得するインスタンス(FIREBASE)
    let BLOCKHOSTSETTER = BlockHostSetterManager()  ///ブロック情報をセットするインスタンス
    let BLOCLHOSTGETTER = BlockHostGetterManager() ///ブロック情報を取得するインスタンス
    let FPC = FloatingPanelController() ///モーダル表示用VC
    let REPORT_FPC = FloatingPanelController()  ///通報表示用VC
    let SEMIMODALTRANSLUCENTVIEW = SemiModalTranslucentView()   ///誤タップ防止VC
    let loadingView = LOADING(loadingView: LoadingView(), BackClear: true)  ///画面ロードビュー
    let ROOMID = chatTools()
    var fromChatViewController:Bool = false
    var TIMETOOL = TimeTools()  ///時間管理
    var bannerAdsView:GADBannerView = GADBannerView() ///バナー広告
    var BLOCKED:BlockKind = .MeNone  ///ブロックされているか
    var BLOCKING:BlockKind = .INone {    ///ブロックしているか
        willSet {
            self.PROFILEVIEW.blockingButtonAction(BLOCK: newValue)
        }
    }
    weak var delegate:ProfileViewControllerDelegate?
    var blockText:String {
        get {
            if BLOCKING == .IBlocked {
                return "ブロック解除"
            } else {
                return "ブロック"
            }
        }
    }
    ///プロフィール画像をローカルから取得
    var IMAGE:UIImage {
        get {
            let IMAGE = IMAGELOCALGETTER.getter(targetUID: TARGETINFO.Required_UID)
            guard let IMAGE else {
                ///初期画像
                let defImage = listUsersImageLocalObject()
                return defImage.profileImage
            }
            ///ローカルに保存してあるImage
            return IMAGE.profileImage
        }
    }
    //モーダルの判断
    enum modalKind {
        case profileEdit
        case report
    }
    var modalState:modalKind?
    var TARGETIMAGE:UIImage?
        

    init(TARGETINFO:RequiredProfileInfoLocalData,SELFINFO:RequiredProfileInfoLocalData,TARGETIMAGE:UIImage?) {
        self.TARGETINFO = TARGETINFO
        self.SELFINFO = SELFINFO
        self.TARGETIMAGE = TARGETIMAGE
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///デリゲート委譲
        PROFILEVIEW.delegate = self
        PROFILEVIEW.nickNameItemView.delegate = self
        PROFILEVIEW.AboutMeItemView.delegate = self
        PROFILEVIEW.areaItemView.delegate = self
        PROFILEVIEW.TargetProfileButtonTappedDelegate = self
        ///半モーダルの初期設定
        FPC.delegate = self
        FPC.layout = CustomFloatingPanelLayout(initialState: .half)
        FPC.isRemovalInteractionEnabled  =  true
        FPC.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        REPORT_FPC.delegate = self
        ///初期メニューアイコン画像設定
        let iconName = TARGETINFO.Required_UID == SELFINFO.Required_UID ? "setting" : "userMenu"
        self.PROFILEVIEW.settingButton.setImage(UIImage(named: iconName), for: .normal)
        ///ローカルデータを使って画面情報をセットアップ
        self.userInfoDataSetup()
    }
    
    ///コードレイアウトで行う場合はLoadView
    override func loadView() {
        self.view = PROFILEVIEW
        if TARGETINFO.Required_UID == SELFINFO.Required_UID {
            PROFILEVIEW.TARGETPROFILE = .SELF
        } else {
            PROFILEVIEW.TARGETPROFILE = .TARGET
            ///スワイプで前画面に戻れるようにする
            edghPanGestureSetting(selfVC: self, selfView: PROFILEVIEW,gestureDirection: .left)
            ///ライクボタンの初期設定
            likePushImageInitSetting()
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ///広告の表示
        mobAdsViewSetting()
        ///相手をブロック中かの確認
        targetBlockingConf()
        ///ふぁぼ数をリアルタイムで取得
        userInfoDataFetchListener()
        ///ライクボタンチェック
        likeButtonAlredyTappedCheck()
        ///プロフィール画像オブジェクトに画像セット
        if TARGETINFO.Required_UID != SELFINFO.Required_UID {
            let TOOL = TIME()
            ///自身じゃない場合は最新画像を取得してローカル保存しておく。(即反映はしない)
            self.PROFILEVIEW.profileImageButton.setImage(TARGETIMAGE, for: .normal)
            CONTETNSHOSTGETTER.MappingDataGetter(callback: { image, err in
                var IMAGELOCALSETTER = ImageDataLocalSetterManager(updateImage: image)
                IMAGELOCALSETTER.commiting = true
            }, UID: TARGETINFO.Required_UID, UpdateTime: TOOL.pastTimeGet())
        } else {
            self.PROFILEVIEW.profileImageButton.setImage(IMAGE, for: .normal)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
    }
}
///EXTENSION[初期設定]
extension ProfileViewController{
    
    /// ライク数取得
    func userInfoDataFetchListener() {
        Firestore.firestore().collection("users").document(TARGETINFO.Required_UID).getDocument{ (document,err) in
            guard let document else {
                return
            }
            guard let favCount = document["likeIncrement"] as? Int else {
                return
            }
            let StringFavCount = String(favCount)
            self.PROFILEVIEW.favInfoLabel.text = StringFavCount
        }
    }
    
    ///各情報のSetUp
    /// - Parameters:
    /// - userInfoData:画面表示の際に取得してきているユーザーデータ
    /// - Returns:
    func userInfoDataSetup() {
        ///性別画像設定
        let gender = GENDER(rawValue: self.TARGETINFO.Required_Sex)
        self.PROFILEVIEW.sexImageView.image = gender?.genderImage
        ///年齢
        let Year = AgeCalculator.conbertDefaultYear(targetYearOfBirth: self.TARGETINFO.Required_Age, minOrMax: .min)
        let Age = AgeCalculator.calculateAge(from: Year)
        self.PROFILEVIEW.ageInfoLabel.text = String("\(Age)歳")
        ///開始日をもってくる際の日付フォーマットの設定
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        let date = TARGETINFO.Required_DateCreatedAt
        ///日付型をStringに変更してラベルにセット
        let userCreatedAtdate:String = dateFormatter.string(from: date)
        self.PROFILEVIEW.startDateInfoLabel.text = userCreatedAtdate
        ///性別を取得。Firebaseでは数値で入っているために数字を判断して性別表示
        switch TARGETINFO.Required_Sex {
        case 0:
            self.PROFILEVIEW.sexInfoLabel.text = "設定なし"
        case 1:
            self.PROFILEVIEW.sexInfoLabel.text = "男性"
        case 2:
            self.PROFILEVIEW.sexInfoLabel.text = "女性"
        default:break
        }
        ///文字列に改行処理を入れる
        let aboutMeMassageValue = TARGETINFO.Required_AboutMeMassage
        let resultValue:String!
        if aboutMeMassageValue.count >= 15 {
            resultValue = aboutMeMassageValue.prefix(15) + "\n" + aboutMeMassageValue.suffix(aboutMeMassageValue.count - 15)
        } else {
            resultValue = aboutMeMassageValue
        }
        guard let resultValue = resultValue else {return}
        ///ニックネームのラベルとニックネームの項目にデータセット
        self.PROFILEVIEW.nickNameItemView.valueLabel.text = TARGETINFO.Required_NickName
        self.PROFILEVIEW.nickNameTopLabel.text = TARGETINFO.Required_NickName
        ///ひとことにデータセット
        self.PROFILEVIEW.AboutMeItemView.valueLabel.text = resultValue
        //出身地にデータセット
        self.PROFILEVIEW.areaItemView.valueLabel.text = TARGETINFO.Required_Area
    }
}


///EXTENSION[ProfileViewから受け取ったデリゲート処理]
extension ProfileViewController:ProfileViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    ///プロフィール画像タップ後の処理
    /// - Parameters:
    /// - Returns: none
    func profileImageButtonTappedDelegate() {
        var selectItem:[String] = []
        if TARGETINFO.Required_UID == SELFINFO.Required_UID {
            selectItem = ["画像を表示","画像を変更"]
        } else {
            selectItem = ["画像を表示"]
        }
        ///アクションシートを表示してユーザーが選択した内容によって動作を切り替え
        createSheet(for: .Options(selectItem, { index in
            switch index {
            case 0:
                self.SHOWIMAGEVIEWCONTROLLER.profileImage = self.PROFILEVIEW.profileImageButton.imageView?.image
                self.present(self.SHOWIMAGEVIEWCONTROLLER, animated: true, completion: nil)
            case 1:
                self.PICKER.delegate = self
                ///強制的にアルバム
                self.PICKER.sourceType = .photoLibrary
                ///カメラピッカー表示
                self.present(self.PICKER, animated: true, completion: nil)
            default:
                return
            }
        }), SelfViewController: self)
    }
    
    ///カメラピッカーでキャンセルを押下した際の処理（デリゲートなので自動で呼ばれる）
    /// - Parameters:
    ///- picker: UIImagePickerController
    /// - Returns: none
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        ///表示していたカメラピッカーViewを閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    
    ///カメラピッカーで写真が選択された際の処理（デリゲートなので自動で呼ばれる）
    /// - Parameters:
    ///- picker: UIImagePickerController
    ///- info: おそらく選択されたイメージ
    /// - Returns: none
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        ///ここでアルバムを表示しているPickerを閉じる
        picker.dismiss(animated: true, completion: nil)
        ///nil判定
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("選択した画像が取得もしくは変換できませんでした")
            return
        }
        ///CropViewControllerのライブラリをインスタンス化
        ///-- croppingStyle:.circular 切り取りスタイルは円形
        ///--image: info[.originalImage] as! UIImage　渡すイメージはアルバムで選択したイメージ
        let cropViewController = CropViewController(croppingStyle: .circular, image: selectedImage)
        cropViewController.delegate = self
        present(cropViewController, animated: true)
    }
    ///CropView Controllerで画像切り取り処理を決定したら呼ばれる処理
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        let MYUID = myProfileSingleton.shared.selfUIDGetter()
        ///UIimageViewをModelインスタンス先で圧縮するためにImageviewをインスタンス化
        let UIimageView = UIImageView()
        UIimageView.image = image
        ///ローカルDBに取得したデータを上書き保存
        let updateImageObject = listUsersImageLocalObject()
        updateImageObject.lcl_UpdataDate = Date()
        updateImageObject.lcl_UID = MYUID
        updateImageObject.profileImage = image
        var IMAGELOCALSETTER = ImageDataLocalSetterManager(updateImage: updateImageObject)
        ///プロフィールイメージ投稿Model
        CONTENTSHOSTSETTER.contentOfFIRStorageUpload(callback: { pressureImage in
            guard let pressureImage = pressureImage else {
                createSheet(for: .Retry(title: "画像更新に失敗しました。"), SelfViewController: self)
                return
            }
            self.PROFILEVIEW.profileImageButton.setImage(pressureImage, for: .normal)
            ///ローカル保存
            IMAGELOCALSETTER.commiting = true
        }, UIimagedata: UIimageView, UID: MYUID)
        
        ///cropViewControllerを閉じる
        cropViewController.dismiss(animated: true, completion: nil)
    }
    ///設定ボタンをタップ後の処理
    func settingButtonTappedDelegate(User: SENDUSER) {
        ///設定ボタンの各項目が押下された後の処理
        switch User {
        case .SELF:
            settingSidemenu()
        case .TARGET:
            //項目設定
            var settingButtonItems = [blockText,"通報"]
            //管理者権限があればUID項目も追加
            let defaults = UserDefaults.standard
            if defaults.bool(forKey: "admin") {
                settingButtonItems.append(TARGETINFO.Required_UID)
            }

            createSheet(for: .Options(settingButtonItems, { selected in
                switch selected {
                ///ブロックボタン押下処理
                case 0:
                    ///現在ブロックしていたら解除
                    if self.BLOCKING == .IBlocked {
                        self.blockPush(Blocking: false)
                    } else {
                    ///現在ブロックしていなかったらブロック
                        self.blockPush(Blocking: true)
                    }
                    return
                case 1:
                    ///通報用VC表示
                    self.reportFpcSetting_Indication()
                    return
                case 2:
                    ///UIDをクリップボードにコピー
                    UIPasteboard.general.string = self.TARGETINFO.Required_UID
                default:
                    return
                }
            }), SelfViewController:  self)
        }
    }
    
    ///編集でキーボードが表示Or非表示になった際の処理
    func keyBoardObserverShowDelegate(Top: CGFloat) {
        FPC.move(to: .full, animated: true)
    }
    
    func keyBoardObserverHideDelegate() {
        FPC.move(to: .half, animated: true)
    }
}

///EXTENSION[プロフィール情報タップ時]
extension ProfileViewController:ProfileChildViewDelegate{
    ///四つの変更項目のどれかが押されたら起動する
    /// - Parameters:
    /// - tag:タグがViewから渡されてくる。このタグによってどの項目かを判断している
    /// - Returns:
    func selfTappedclearButton(tag: Int) {
        //戻ってきてすぐに同じボタンをタップされてしまった際を想定してfpcに親が存在していたらリターンする
        guard FPC.parent == nil else {
            return
        }
        //モーダル状態を指定
        self.modalState = .profileEdit
        self.tabBarController?.tabBar.isHidden = true
        self.view.addSubview(SEMIMODALTRANSLUCENTVIEW)
        SEMIMODALTRANSLUCENTVIEW.delegate = self
        switch tag{
        case 1:
            let semiModalViewController = SemiModalViewController(dicidedModal: .nickName, SELFPROFILE: TARGETINFO)
            FPC.set(contentViewController: semiModalViewController)
            semiModalViewController.delegate = self
            FPC.addPanel(toParent: self, at: -1, animated: true, completion: nil)
        case 2:
            let semiModalViewController = SemiModalViewController(dicidedModal: .aboutMe, SELFPROFILE: TARGETINFO)
            FPC.set(contentViewController: semiModalViewController)
            semiModalViewController.delegate = self
            FPC.addPanel(toParent: self, at: -1, animated: true, completion: nil)
        case 4:
            let semiModalViewController = SemiModalViewController(dicidedModal: .Area, SELFPROFILE: TARGETINFO)
            FPC.set(contentViewController: semiModalViewController)
            semiModalViewController.delegate = self
            FPC.addPanel(toParent: self, at: -1, animated: true, completion: nil)
        default:break
        }
    }
}

///EXTENSION[セミモーダルライブラリの適用]
extension ProfileViewController:FloatingPanelControllerDelegate,SemiModalTranslucentViewProtcol{
    func TranslucentViewTappedDelegate() {
        switch self.modalState {
        case .profileEdit:
            FPC.removePanelFromParent(animated: true)
        case .report:
            REPORT_FPC.removePanelFromParent(animated: true)
        case .none:
            break
        }
    }
    
    // カスタマイズしたレイアウトに変更(デフォルトで使用する際は不要)
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        switch self.modalState {
        case .profileEdit:
            return CustomFloatingPanelLayout(initialState: .half)
        case .report:
            return CustomFloatingPanelLayout(initialState: .full)
        case .none:
            return CustomFloatingPanelLayout(initialState: .half)
        }
    }

    ///fpcを閉じる
    func removesemiModal(){
        switch self.modalState {
        case .profileEdit:
            FPC.removePanelFromParent(animated: true)
        case .report:
            REPORT_FPC.removePanelFromParent(animated: true)
        case .none:
            FPC.removePanelFromParent(animated: true)
        }
       
    }
    ///fpcが破棄された時に呼ばれる。（ちなみにユーザーが下にスワイプして画面からfpcが見えなくなっても呼ばれる）
    func floatingPanelWillRemove(_ fpc: FloatingPanelController) {
        if self.modalState == .profileEdit {
            ///後ろのブラービューを破棄
            SEMIMODALTRANSLUCENTVIEW.removeFromSuperview()
            ///破棄時にデータセットアップ
            self.userInfoDataSetup()
            self.tabBarController?.tabBar.isHidden = false
        }
    }
}

///EXTENSION[サイドメニュー関連の拡張]
extension ProfileViewController:SideMenuViewControllerDelegate{
    ///サイドメニュー表示
    func settingSidemenu() {
        
        let MenuNavigationController = SideMenuNavigationController(rootViewController: SIDEMENUVIEWCONTROLLER)
        MenuNavigationController.settings = makeSettings()
        present(MenuNavigationController, animated: true, completion: nil)
    }
    ///サイドメニューの設定内容
    private func makeSettings() -> SideMenuSettings {
        ///スライドスタイル
        let presentationStyle: SideMenuPresentationStyle = .viewSlideOutMenuOut
        ///陰影をつけて立体的に
        presentationStyle.onTopShadowOpacity = 1.0
        var settings = SideMenuSettings()
        settings.presentationStyle = presentationStyle
        ///SafeAriaまで表示しない。
        settings.statusBarEndAlpha = 100
        return settings
    }
    func pushViewController(nextViewController: UIViewController, sideMenuViewcontroller: SideMenuViewcontroller) {
        sideMenuViewcontroller.dismiss(animated: false, completion: nil)
        let UINavigationController = UINavigationController(rootViewController: nextViewController)
        UINavigationController.modalPresentationStyle = .fullScreen
        present(UINavigationController, animated: true, completion: nil)
    }
    
}
///EXTENSION[デリゲート]
extension ProfileViewController:SemiModalViewControllerProtcol{
    /// モーダルビューの決定ボタンを押下
    func ButtonTappedActionChildDelegateAction() {
        ///FPC破棄
        FPC.removePanelFromParent(animated: true)
    }
}

///EXTENSION[各種機能群]
extension ProfileViewController:TargetProfileButtonDelegate{

    func invalidUserCompletion() {
            createSheet(for: .Completion(title: "不正なユーザーの可能性があるため強制終了します。再登録してください。", {
                preconditionFailure()
            }), SelfViewController: self)
        }
    
    func buckButtonTappedDelegate() {
        ///相手をブロックしていたらユーザー一覧画面にIDを渡す
        if BLOCKING == .IBlocked {
            delegate?.blockUserReport(userID: TARGETINFO.Required_UID)
        }
        self.dismiss(animated: true, completion: nil)
        self.slideOutToLeft()
    }
    
    func likePushImageInitSetting() {
        if TARGETINFO.Required_LikeButtonPushedFLAG == true {
            PROFILEVIEW.likePushButton.isEnabled = false
            PROFILEVIEW.likeAnimationSetting(pushValue: true)
        } else {
            PROFILEVIEW.likePushButton.isEnabled = true
            PROFILEVIEW.likeAnimationSetting(pushValue: false)
        }
    }

    ///ライクボタン押下
    func likePushButtonTappedDelegate() {
        ///ブロックしていたらメッセージを出してReturn
        if BLOCKING == .IBlocked {
            createSheet(for: .Alert(title: "ブロック中", message: "送信する場合は解除してください。", buttonMessage: "OK", { _ in
            }), SelfViewController: self)
            return
        }
        
        ///ここが有効化されるには、トークリストの情報を取得するまで待機するようにする。
        ///押下されたら連続では押せなくする
        PROFILEVIEW.likePushButton.isEnabled = false
        ///ロード画面
        loadingView.loadingViewIndicator(isVisible: true)
        ///ルームID作成
        let RoomID = ROOMID.roomIDCreate(UID1: SELFINFO.Required_UID, UID2: TARGETINFO.Required_UID)
        ///更新処理
        hostAndlocalProfileDataCreateAndRegister(roomID: RoomID)
    }
    ///ローカル保存とライク情報送信
    func hostAndlocalProfileDataCreateAndRegister(roomID:String) {
        ///コミット可否
        var CommitFlag:Bool = true
        ///Update用新規アンマネージドオブジェクト
        var UpdateProfile = ProfileInfoLocalObject()
        ///アンマネージドオブジェクトの更新対象以外をマッピング
        UpdateProfile = realmMapping.updateObjectMapping(unManagedObject: UpdateProfile, managedObject: TARGETINFO)
        UpdateProfile.lcl_LikeButtonPushedFLAG = true
        UpdateProfile.lcl_LikeButtonPushedDate = Date()

        ///ローカル保存開始
        var profileDataSetter = TargetProfileLocalDataSetterManager(updateProfile: UpdateProfile)
        ///サーバ処理失敗時のクロージャ
        let failedToRetry = {
            err(Type: .likeButtonInvalid, TargetVC: self)
            CommitFlag = false
            ///ロードインジケータ非表示
            self.loadingView.loadingViewIndicator(isVisible: false)
            return
        }
        ///ブロックデータ
        var blked:Bool {
            get {
                if self.BLOCKED == .Meblocked {
                    return true
                } else {
                    return false
                }
            }
        }
        ///サーバー保存
        ///それぞれのトーク情報とチャット情報にライク情報を送信
        let message = Message(Entity: MessageEntity(message: "", senderID: self.SELFINFO.Required_UID, displayName: self.SELFINFO.Required_NickName, messageID: UUID().uuidString, sentDate:  Date(), DateGroupFlg: false, SENDUSER: .SELF))
        CHATDATAHOSTSETTER.messageUpload(callback: { err in
            ///チャット失敗
            if let err = err {
                failedToRetry()
                ///ロードインジケータ非表示
                self.loadingView.loadingViewIndicator(isVisible: false)
                self.PROFILEVIEW.likePushButton.isEnabled = true
                return
            }
            
            ///それぞれのトークリストを更新
            self.LISTDATAHOSTINGSETTER.talkListToUserInfoSetter(
                callback: {hostingresult in
                    ///トークリスト更新失敗
                    guard hostingresult else {
                        failedToRetry()
                        ///ロードインジケータ非表示
                        self.loadingView.loadingViewIndicator(isVisible: false)
                        self.PROFILEVIEW.likePushButton.isEnabled = true
                        return
                    }
                    ///トランザクション中のローカルデータもコミット
                    CommitFlag = true
                    ///ロードインジケータ非表示
                    self.loadingView.loadingViewIndicator(isVisible: false)
                    ///ライクボタンアニメーション実施
                    self.PROFILEVIEW.likeAnimationPlay()
                    return
                }, UID1: self.SELFINFO.Required_UID,UID2: self.TARGETINFO.Required_UID,message: "",
                sender: self.SELFINFO.Required_UID,nickName1: self.SELFINFO.Required_NickName,
                nickName2: self.TARGETINFO.Required_NickName,like: true,blocked: false
            )
            
        }, Message: message, text: "", roomID: roomID, Like: true, receiverID: TARGETINFO.Required_UID, senderNickname: self.SELFINFO.Required_NickName)
        
        DispatchQueue.main.async {
            profileDataSetter.commiting = CommitFlag
        }
    }
    ///メッセージボタン押下
    func forMessageButtonDelegate() {
        ///チャットビューから来ていた場合は戻るだけで終わり
        if fromChatViewController {
            self.dismiss(animated: true, completion: nil)
            self.slideOutToLeft()
            return
        }
        ///ロードビュー表示
        loadingView.loadingViewIndicator(isVisible: true)
        ///タップした時点で相手の最新の情報を取得する
        PLOFILEHOSTGETTER.mappingDataGetter(callback: { InfoLocal, err in
            ///ロードビュー非表示
            self.loadingView.loadingViewIndicator(isVisible: false)
            if err == nil {
                ///安全なデータにマッピング
                guard let TARGETPROFILE = realmMapping.profileDataMapping(PROFILE: InfoLocal, VC: self) else {
                    return
                }
                ///遷移先の画面
                let chatViewController = ChatViewController(selfProfile: self.SELFINFO, targetProfile: TARGETPROFILE, SELFPROFILEIMAGE:self.IMAGE, TARGETPROFILEIMAGE: self.TARGETIMAGE ?? UIImage(named:"defProfile")!)
                let UINavigationController = UINavigationController(rootViewController: chatViewController)
                UINavigationController.modalPresentationStyle = .fullScreen
                self.present(UINavigationController, animated: false, completion: nil)
                self.slideInFromRight() // 遷移先の画面を横スライドで表示
                ///タブバーをチャットリストに移動
                self.tabBarController?.selectedIndex = 1
            } else {

            }
        }, UID: TARGETINFO.Required_UID)
    }
}
//通報関連
extension ProfileViewController:reportViewControllerDelegate {
    func reportFpcSetting_Indication() {
        //モーダル状態を指定
        self.modalState = .report
        REPORT_FPC.layout = CustomFloatingPanelLayout(initialState: .full)
        REPORT_FPC.isRemovalInteractionEnabled  =  true
        REPORT_FPC.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        var loomID:String = ROOMID.roomIDCreate(UID1: SELFINFO.Required_UID, UID2: TARGETINFO.Required_UID)
        let reportViewController = ReportViewController(roomID: loomID, selfInfo: SELFINFO, targetInfo: TARGETINFO)
        reportViewController.delegate = self
        REPORT_FPC.set(contentViewController: reportViewController)
        REPORT_FPC.addPanel(toParent: self, at: -1, animated: true, completion: nil)
    }
    ///通報が完了したらFPCを閉じる。
    func removeFPC() {
        removesemiModal()
    }
}

//ブロック関連
extension ProfileViewController {
    ///ブロック押下時
    func blockPush(Blocking:Bool) {
        ///ロードビュー表示
        loadingView.loadingViewIndicator(isVisible: true)
        ///ブロック登録処理
        BLOCKHOSTSETTER.blockingOperater(callback: { result in
            ///ロードビュー非表示
            self.loadingView.loadingViewIndicator(isVisible: false)
            if !result {
                createSheet(for: .Retry(title: "ブロック処理に失敗しました。再度試してください"), SelfViewController: self)
            } else {
                if Blocking {
                    ///ブロック成功
                    self .BLOCKING = .IBlocked
                } else {
                    ///ブロック解除成功
                    self .BLOCKING = .INone
                }
            }
        }, MyUID: SELFINFO.Required_UID, targetUID: TARGETINFO.Required_UID, block: Blocking, nickname: TARGETINFO.Required_NickName)
    }
    
    ///ブロックサーバー確認
    func targetBlockingConf() {
        BLOCLHOSTGETTER.targetBlockConfListener(callback: { BlockKind in
            switch BlockKind {
            case .INone:
                self.BLOCKING = .INone
                return
            case .MeNone:
                self.BLOCKED = .MeNone
            case .IBlocked:
                self.BLOCKING = .IBlocked
                return
            case .Meblocked:
                self.BLOCKED = .Meblocked
                return
            }
        }, targetUID: TARGETINFO.Required_UID, selfUID: SELFINFO.Required_UID)
    }
}

extension ProfileViewController{
    ///ライクボタン押下済み判断
    func likeButtonAlredyTappedCheck() {
        ///ライク押下データ処理
        if let pushDate = TARGETINFO.Required_LikeButtonPushedDate{
            if TIMETOOL.pushTimeDiffDate(pushTime: pushDate) {
                ///ライクボタンアニメーション実施
                PROFILEVIEW.likePushImageView.currentProgress = 1
                ///押せなくする
                PROFILEVIEW.likePushButton.isEnabled = false
            }
        }
    }
}

///広告の実装
extension ProfileViewController {
    ///バナー広告
    func mobAdsViewSetting() {
        
        bannerAdsView.adUnitID = ADSInfoSingleton.shared.bannerAdUnitID      /// 追記
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
