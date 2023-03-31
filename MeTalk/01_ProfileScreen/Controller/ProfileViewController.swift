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

class ProfileViewController:UIViewController, CropViewControllerDelegate{

    ///認証状態をリッスンする変数定義
    var handle:AuthStateDidChangeListenerHandle?
    ///カメラピッカーの定義
    let PICKER = UIImagePickerController()
    

    ///インスタンス化(Controller)
    var contentVC:UIViewController?
    let SIDEMENUVIEWCONTROLLER = SideMenuViewcontroller()
    let SHOWIMAGEVIEWCONTROLLER = ShowImageViewController()
    ///インスタンス化（View）
    let PROFILEVIEW = ProfileView()
    ///インスタンス化（Model）
    let USERDATAMANAGE = UserDataManage()
    let UID = Auth.auth().currentUser?.uid
    let localData = profileDataStruct(UID: Auth.auth().currentUser!.uid)
    ///RealMオブジェクトをインスタンス化
    let REALM = try! Realm()
    ///プロフィール情報を保存する辞書型変数
    var profileData:profileInfoLocal?
    var profileImage:UIImage?
    
    ///ライブラリのハンモーダルインスタンス
    let FPC = FloatingPanelController()
    ///後ろにいるビューコントローラー（このビューコントローラー）をタップできないようにするためのView
    let SEMIMODALTRANSLUCENTVIEW = SemiModalTranslucentView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///デリゲート委譲
        PROFILEVIEW.delegate = self
        PROFILEVIEW.nickNameItemView.delegate = self
        PROFILEVIEW.AboutMeItemView.delegate = self
        PROFILEVIEW.ageItemView.delegate = self
        PROFILEVIEW.areaItemView.delegate = self
        SIDEMENUVIEWCONTROLLER.delegate = self
        
//        ///半モーダルの初期設定
        FPC.delegate = self
        FPC.layout = CustomFloatingPanelLayout()
        FPC.isRemovalInteractionEnabled  =  true
        FPC.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        ///初期画像設定
        self.PROFILEVIEW.settingButton.setImage(UIImage(named: "setting"), for: .normal)

        ///ローカルデータを使って画面情報をセットアップ
        localData.userProfileDatalocalGet { Ldata, err in
            if err != nil {
                self.hostingDataGetter()
                return
            }
            self.userInfoDataSetup(userInfoData: Ldata)
        }
    }
    
    func hostingDataGetter() {
        let hosting = profileHosting()
        hosting.FireStoreProfileDataGetter(callback: { info, err in
            if err != nil {
                print("サーバーにデータがないのに初期画面以外にいるのはありえない")
            }
            self.userInfoDataSetup(userInfoData: info)
        }, UID: UID!)
    }
    
    ///コードレイアウトで行う場合はLoadView
    override func loadView() {
        self.view = PROFILEVIEW
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ///ローカルDBインスンス化
        let IMAGELOCALDATASTRUCT = chatUserListLocalImageInfoGet(UID: UID!)
        ///プロフィール画像オブジェクトに画像セット（ローカル）
        self.PROFILEVIEW.profileImageButton.setImage(IMAGELOCALDATASTRUCT.image, for: .normal)
        self.profileImage = IMAGELOCALDATASTRUCT.image

        ///サーバーに対して画像取得要求（ローカルとの差分更新）
        USERDATAMANAGE.contentOfFIRStorageGet(callback: { imageStruct in
            ///取得してきた画像がNilの場合初期画像セット
            guard let image = imageStruct.image else {
                self.PROFILEVIEW.profileImageButton.setImage(UIImage(named: "InitIMage"), for: .normal)
                return
            }
            ///イメージ画像をオブジェクトにセット（サーバー）
            self.PROFILEVIEW.profileImageButton.setImage(image, for: .normal)
            ///ローカルDBに取得したデータを上書き保存
            chatUserListLocalImageRegist(UID: self.UID!, profileImage: imageStruct.image!, updataDate: imageStruct.upDateDate)
            
        }, UID: UID, UpdateTime: IMAGELOCALDATASTRUCT.upDateDate)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
        }
}



///※ProfileViewから受け取ったデリゲート処理※
extension ProfileViewController:ProfileViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    ///プロフィール画像タップ後の処理
    /// - Parameters:
    /// - Returns: none
    func profileImageButtonTappedDelegate() {
        ///アクションシートを表示してユーザーが選択した内容によって動作を切り替え
        let action = actionSheets(twoAtcionTitle1: "画像を表示", twoAtcionTitle2: "画像を変更")
        
        action.showTwoActionSheets(callback: { result in
            switch result {
                ///画像を表示
            case .one:
                self.SHOWIMAGEVIEWCONTROLLER.profileImage = self.profileImage
                self.present(self.SHOWIMAGEVIEWCONTROLLER, animated: true, completion: nil)
                ///画像を変更
            case .two:
                self.PICKER.delegate = self
                ///強制的にアルバム
                self.PICKER.sourceType = .photoLibrary
                ///カメラピッカー表示
                self.present(self.PICKER, animated: true, completion: nil)
            }
        }, SelfViewController: self)
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

        ///UIimageViewをModelインスタンス先で圧縮するためにImageviewをインスタンス化
        let UIimageView = UIImageView()
        UIimageView.image = image
        ///プロフィールイメージ投稿Model
        USERDATAMANAGE.contentOfFIRStorageUpload(callback: { pressureImage in
            self.PROFILEVIEW.profileImageButton.setImage(pressureImage, for: .normal)
            ///ローカルDBに取得したデータを上書き保存
            chatUserListLocalImageRegist(UID: self.UID!, profileImage: pressureImage!, updataDate: Date())
        }, UIimagedata: UIimageView, UID: UID)
        
        ///cropViewControllerを閉じる
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    ///設定ボタンをタップ後の処理
    func settingButtonTappedDelegate() {
        settingSidemenu()
    }
    
}

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
        self.tabBarController?.tabBar.isHidden = true
        self.view.addSubview(SEMIMODALTRANSLUCENTVIEW)
        switch tag{
        case 1:
            let semiModalViewController = SemiModalViewController(dicidedModal: .nickName)
            FPC.set(contentViewController: semiModalViewController)
            semiModalViewController.delegate = self
            FPC.addPanel(toParent: self, at: -1, animated: true, completion: nil)
        case 2:
            let semiModalViewController = SemiModalViewController(dicidedModal: .aboutMe)
            FPC.set(contentViewController: semiModalViewController)
            semiModalViewController.delegate = self
            FPC.addPanel(toParent: self, at: -1, animated: true, completion: nil)
        case 3:
            let semiModalViewController = SemiModalViewController(dicidedModal: .Age)
            FPC.set(contentViewController: semiModalViewController)
            semiModalViewController.delegate = self
            FPC.addPanel(toParent: self, at: -1, animated: true, completion: nil)
        case 4:
            let semiModalViewController = SemiModalViewController(dicidedModal: .Area)
            FPC.set(contentViewController: semiModalViewController)
            semiModalViewController.delegate = self
            FPC.addPanel(toParent: self, at: -1, animated: true, completion: nil)
        default:break
        }
    }
}


extension ProfileViewController{
    ///各情報のSetUp
    /// - Parameters:
    /// - userInfoData:画面表示の際に取得してきているユーザーデータ
    /// - Returns:
    func userInfoDataSetup(userInfoData:profileInfoLocal) {
        ///開始日をもってくる際の日付フォーマットの設定
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        let dateUnix = userInfoData["createdAt"] as? Timestamp
        let date = dateUnix?.dateValue() ?? Date()
        ///日付型をStringに変更してラベルにセット
        let userCreatedAtdate:String = dateFormatter.string(from: date as Date)
        self.PROFILEVIEW.startDateInfoLabel.text = userCreatedAtdate
        ///性別を取得。Firebaseでは数値で入っているために数字を判断して性別表示
        switch userInfoData["Sex"] as? Int {
        case 0:
            self.PROFILEVIEW.sexInfoLabel.text = "設定なし"
        case 1:
            self.PROFILEVIEW.sexInfoLabel.text = "男性"
        case 2:
            self.PROFILEVIEW.sexInfoLabel.text = "女性"
        default:break
        }
        ///文字列に改行処理を入れる
        let aboutMeMassageValue = userInfoData["aboutMeMassage"] as? String
        let resultValue:String!
        guard let aboutMeMassageValue = aboutMeMassageValue else {
            return
        }
        if aboutMeMassageValue.count >= 15 {
            resultValue = aboutMeMassageValue.prefix(15) + "\n" + aboutMeMassageValue.suffix(aboutMeMassageValue.count - 15)
            print(resultValue)
        } else {
            resultValue = aboutMeMassageValue
        }
        guard let resultValue = resultValue else {return}
        ///ニックネームのラベルとニックネームの項目にデータセット
        
        self.PROFILEVIEW.nickNameItemView.valueLabel.text = userInfoData["nickname"] as? String
        self.PROFILEVIEW.personalInformationLabel.text = userInfoData["nickname"] as? String
        ///ひとことにデータセット
        self.PROFILEVIEW.AboutMeItemView.valueLabel.text = resultValue
        //年齢にデータセット
        guard let ageTypeInt:Int = userInfoData["age"] as? Int else {
            print("年齢を取得できませんでした。")
            return
        }
        if String(ageTypeInt)  == "0" {
            self.PROFILEVIEW.ageItemView.valueLabel.text = "未設定"
        } else {
            self.PROFILEVIEW.ageItemView.valueLabel.text = String(ageTypeInt)
        }
        
        //出身地にデータセット
        self.PROFILEVIEW.areaItemView.valueLabel.text = userInfoData["area"] as? String
    }
    
}

///セミモーダルライブラリの適用
extension ProfileViewController:FloatingPanelControllerDelegate{
    // カスタマイズしたレイアウトに変更(デフォルトで使用する際は不要)
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        return CustomFloatingPanelLayout()
    }

    ///FPCをどの位置でRemoveするかを決める
    func floatingPanel(_ fpc: FloatingPanelController, shouldRemoveAt location: CGPoint, with velocity: CGVector) -> Bool {
        ///下にドラッグした瞬間にRemoveしたいので0と0
        location.equalTo(CGPoint(x: 0, y: 0))
        return true
    }
    
    ///fpcを閉じる
    func removesemiModal(){
        FPC.removePanelFromParent(animated: true)
    }
    ///fpcが破棄された時に呼ばれる。（ちなみにユーザーが下にスワイプして画面からfpcが見えなくなっても呼ばれる）
    func floatingPanelWillRemove(_ fpc: FloatingPanelController) {
        ///後ろのブラービューを破棄
        SEMIMODALTRANSLUCENTVIEW.removeFromSuperview()
        
        ///破棄時にデータセットアップ
        localData.userProfileDatalocalGet { Ldata, err in
            if err != nil {
                self.hostingDataGetter()
                return
            }
            self.userInfoDataSetup(userInfoData: Ldata)
        }
        
        self.tabBarController?.tabBar.isHidden = false
    }
}

///サイドメニュー関連の拡張
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

///SemiModalViewControllerからのデリゲート処理で、二ついれこになっている。大元のデリゲート処理は
///ここのViewControllerであるProfileViewController。さらにそこからfpcで追加したSemiModalViewController。
///さらにSemiModalViewControllerのViewで追加した各Viewの決定ボタンが大元の発火処理になっている。
///fpcを取り除く処理をしなくてはならないためにsemiModalViewControllerからさらにこのコントローラにデリゲートして処理を行なっている。
extension ProfileViewController:SemiModalViewControllerProtcol{
    func ButtonTappedActionChildDelegateAction() {
        FPC.removePanelFromParent(animated: true)
    }
}

//この画面のエクステンションでオブザーバが実装できるか確認
