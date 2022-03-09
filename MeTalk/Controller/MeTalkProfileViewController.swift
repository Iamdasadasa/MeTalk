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

class MeTalkProfileViewController:UIViewController, CropViewControllerDelegate{

    
    ///認証状態をリッスンする変数定義
    var handle:AuthStateDidChangeListenerHandle?
    ///UID格納変数
    var UID:String?
    ///カメラピッカーの定義
    let picker = UIImagePickerController()
    ///インスタンス化(Controller)
    var contentVC:UIViewController?
    var showImageViewController = ShowImageViewController()
    var sideMenuViewController = SideMenuViewcontroller()
    ///インスタンス化（View）
    let meTalkProfileView = MeTalkProfileView()
    ///インスタンス化（Model）
    let userDataManagedData = UserDataManagedData()
    let storage = Storage.storage()
    let host = "gs://metalk-f132e.appspot.com"
    
    ///ライブラリのハンモーダルインスタンス
    var fpc = FloatingPanelController()
    ///後ろにいるビューコントローラー（このビューコントローラー）をタップできないようにするためのView
    let semiModalTranslucentView = SemiModalTranslucentView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///デリゲート委譲
        meTalkProfileView.delegate = self
        meTalkProfileView.nickNameItemView.delegate = self
        meTalkProfileView.AboutMeItemView.delegate = self
        meTalkProfileView.ageItemView.delegate = self
        meTalkProfileView.areaItemView.delegate = self
        sideMenuViewController.delegate = self
        
//        ///半モーダルの初期設定
        fpc.delegate = self
        fpc.layout = CustomFloatingPanelLayout()
        fpc.isRemovalInteractionEnabled  =  true
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        ///初期画像設定
        self.meTalkProfileView.settingButton.setImage(UIImage(named: "setting"), for: .normal)
        ///画面表示前にユーザー情報を取得
        userDataManagedData.userInfoDataGet(callback: {document in
            guard let document = document else {
                return
            }
            self.userInfoDataSetup(userInfoData: document)
        })
    }
    
    override func viewDidLayoutSubviews() {
        self.view = meTalkProfileView
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
            ///自身のプロフィール画像を取ってくる
            self.userDataManagedData.contentOfFIRStorageGet(callback: { image in
                ///Nilでない場合はコールバック関数で返ってきたイメージ画像をオブジェクトにセット
                if image != nil {
                    self.meTalkProfileView.profileImageButton.setImage(image, for: .normal)
                ///コールバック関数でNilが返ってきたら初期画像を設定
                } else {
                    self.meTalkProfileView.profileImageButton.setImage(UIImage(named: "InitIMage"), for: .normal)
                }
            })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
        }
    
}



///※MeTalkProfileViewから受け取ったデリゲート処理※
extension MeTalkProfileViewController:MeTalkProfileViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    ///プロフィール画像タップ後の処理
    /// - Parameters:
    /// - Returns: none
    func profileImageButtonTappedDelegate() {
        ///アクションシートを表示してユーザーが選択した内容によって動作を切り替え
        profileImageActionSheet(callback: {actionFlg in
            if let actionFlg = actionFlg {
                switch actionFlg{
                ///画像を表示
                case 1:
                    self.present(self.showImageViewController, animated: true, completion: nil)
                ///画像を変更
                case 2:
                    self.picker.delegate = self
                    ///強制的にアルバム
                    self.picker.sourceType = .photoLibrary
                    ///カメラピッカー表示
                    self.present(self.picker, animated: true, completion: nil)
                default:
                    break
                }
            }
        })
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
        userDataManagedData.contentOfFIRStorageUpload(callback: { pressureImage in
            self.meTalkProfileView.profileImageButton.setImage(pressureImage, for: .normal)
        }, UIimagedata: UIimageView)
        
        ///cropViewControllerを閉じる
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    ///開発用　サインアウトボタンタップ時の挙動
//    func signoutButtonTappedDelegate() {
//        do {
//            try Auth.auth().signOut()
//        } catch let signOutError as NSError {
//            print("SignOut Error: %@", signOutError)
//        }
//    }
    ///設定ボタンをタップ後の処理
    func settingButtonTappedDelegate() {
        settingSidemenu()
        print("設定ボタンが押下")
    }
    
}

///プロフィール画像を選択した際のアクションシート
extension MeTalkProfileViewController{
    func profileImageActionSheet(callback:@escaping (Int?) -> Void){
        var actionFlg:Int?
        //アクションシートを作る
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        //ボタン1
        alert.addAction(UIAlertAction(title: "画像を表示", style: .default, handler: {
            (action: UIAlertAction!) in
            actionFlg = 1
            callback(actionFlg)
        }))

        //ボタン２
        alert.addAction(UIAlertAction(title: "画像を変更", style: .default, handler: {
            (action: UIAlertAction!) in
            actionFlg = 2
            callback(actionFlg)
        }))

        //ボタン３
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))

        //アクションシートを表示する
        self.present(alert, animated: true, completion: nil)
        

    }
}

extension MeTalkProfileViewController:MeTalkProfileChildViewDelegate{
    ///四つの変更項目のどれかが押されたら起動する
    /// - Parameters:
    /// - tag:タグがViewから渡されてくる。このタグによってどの項目かを判断している
    /// - Returns:
    func selfTappedclearButton(tag: Int) {
        //戻ってきてすぐに同じボタンをタップされてしまった際を想定してfpcに親が存在していたらリターンする
        guard fpc.parent == nil else {
            return
        }
        self.tabBarController?.tabBar.isHidden = true
        self.view.addSubview(semiModalTranslucentView)
        switch tag{
        case 1:
            let semiModalViewController = SemiModalViewController(viewFlg: 1)
            fpc.set(contentViewController: semiModalViewController)
            semiModalViewController.delegate = self
            fpc.addPanel(toParent: self)
        case 2:
            let semiModalViewController = SemiModalViewController(viewFlg: 2)
            fpc.set(contentViewController: semiModalViewController)
            semiModalViewController.delegate = self
            fpc.addPanel(toParent: self)
        case 3:
            let semiModalViewController = SemiModalViewController(viewFlg: 3)
            fpc.set(contentViewController: semiModalViewController)
            semiModalViewController.delegate = self
            fpc.addPanel(toParent: self)
        case 4:
            let semiModalViewController = SemiModalViewController(viewFlg: 4)
            fpc.set(contentViewController: semiModalViewController)
            semiModalViewController.delegate = self
            fpc.addPanel(toParent: self)
        default:break
        }
        
    }
    
}


extension MeTalkProfileViewController{
    ///各情報のSetUp
    /// - Parameters:
    /// - userInfoData:画面表示の際に取得してきているユーザーデータ
    /// - Returns:
    func userInfoDataSetup(userInfoData:[String:Any]) {
        ///開始日をもってくる際の日付フォーマットの設定
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        let dateUnix = userInfoData["createdAt"] as! Timestamp
        let date = dateUnix.dateValue()
        ///日付型をStringに変更してラベルにセット
        let userCreatedAtdate:String = dateFormatter.string(from: date as Date)
        self.meTalkProfileView.startDateInfoLabel.text = userCreatedAtdate
        ///性別を取得。Firebaseでは数値で入っているために数字を判断して性別表示
        switch userInfoData["Sex"] as? Int {
        case 0:
            self.meTalkProfileView.sexInfoLabel.text = "設定なし"
        case 1:
            self.meTalkProfileView.sexInfoLabel.text = "男性"
        case 2:
            self.meTalkProfileView.sexInfoLabel.text = "女性"
        default:break
        }
        ///文字列に改行処理を入れる
        let aboutMeMassageValue = userInfoData["aboutMeMassage"] as? String
        let resultValue:String!
        guard let aboutMeMassageValue = aboutMeMassageValue else { return }
        if aboutMeMassageValue.count >= 15 {
            resultValue = aboutMeMassageValue.prefix(15) + "\n" + aboutMeMassageValue.suffix(aboutMeMassageValue.count - 15)
            print(resultValue)
        } else {
            resultValue = aboutMeMassageValue
        }
        guard let resultValue = resultValue else {return}
        ///ニックネームのラベルとニックネームの項目にデータセット
        self.meTalkProfileView.nickNameItemView.valueLabel.text = userInfoData["nickname"] as? String
        self.meTalkProfileView.personalInformationLabel.text = userInfoData["nickname"] as? String
        ///ひとことにデータセット
        self.meTalkProfileView.AboutMeItemView.valueLabel.text = resultValue
        //年齢にデータセット
        guard let ageTypeInt:Int = userInfoData["age"] as? Int else {
            print("年齢を取得できませんでした。")
            return
        }
        if String(ageTypeInt)  == "0" {
            self.meTalkProfileView.ageItemView.valueLabel.text = "未設定"
        } else {
            self.meTalkProfileView.ageItemView.valueLabel.text = String(ageTypeInt)
        }
        
        //出身地にデータセット
        self.meTalkProfileView.areaItemView.valueLabel.text = userInfoData["area"] as? String
    }
    
}

///セミモーダルライブラリの適用
extension MeTalkProfileViewController:FloatingPanelControllerDelegate{
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
        fpc.removePanelFromParent(animated: true)
    }
    ///fpcが破棄された時に呼ばれる。（ちなみにユーザーが下にスワイプして画面からfpcが見えなくなっても呼ばれる）
    func floatingPanelWillRemove(_ fpc: FloatingPanelController) {
        ///後ろのブラービューを破棄
        semiModalTranslucentView.removeFromSuperview()
        ///ユーザー情報を再取得
        userDataManagedData.userInfoDataGet(callback: {document in
            guard let document = document else {
                return
            }
            self.userInfoDataSetup(userInfoData: document)
        })
        ///タブバーコントローラーを表示
        self.tabBarController?.tabBar.isHidden = false

    }
}

///サイドメニュー関連の拡張
extension MeTalkProfileViewController:SideMenuViewControllerDelegate{
    ///サイドメニュー表示
    func settingSidemenu() {
        
        let MenuNavigationController = SideMenuNavigationController(rootViewController: sideMenuViewController)
        MenuNavigationController.settings = makeSettings()
//        MenuNavigationController.
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
        sideMenuViewcontroller.dismiss(animated: true, completion: nil)
        self.navigationController.pushViewController(nextViewController, animated: true)
    }
    
}

///SemiModalViewControllerからのデリゲート処理で、二ついれこになっている。大元のデリゲート処理は
///ここのViewControllerであるMeTalkProfileViewController。さらにそこからfpcで追加したSemiModalViewController。
///さらにSemiModalViewControllerのViewで追加した各Viewの決定ボタンが大元の発火処理になっている。
///fpcを取り除く処理をしなくてはならないためにsemiModalViewControllerからさらにこのコントローラにデリゲートして処理を行なっている。
extension MeTalkProfileViewController:SemiModalViewControllerProtcol{
    func ButtonTappedActionChildDelegateAction() {
        fpc.removePanelFromParent(animated: true)
    }
}
