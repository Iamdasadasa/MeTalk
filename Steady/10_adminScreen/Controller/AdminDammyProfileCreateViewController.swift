//
//  AdminDammyProfileCreateViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/11/07.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import Photos
import FloatingPanel
import CropViewController

class AdminDammyProfileCreateViewController:UIViewController{
    
    let SHOWIMAGEVIEWCONTROLLER = ShowImageViewController()    ///画像表示ビュー
    let ADMINDAMMYVIEW = AdminDammyProfileCreateView()
    let FPC = FloatingPanelController() ///モーダル表示用VC
    let CONTENTSHOSTSETTER = ContentsHostSetter()   ///画像データを保存するインスタンス(Firebase)
    let REGISTERHOSTSETTER = RegisterHostSetter()
    let ADMINHOSTSETTER = adminHostSetterManager()
    let SEMIMODALTRANSLUCENTVIEW = SemiModalTranslucentView()   ///誤タップ防止VC
    let PICKER = UIImagePickerController()    ///カメラピッカー
    var semiModalViewController:AdminDammyProfileCreateModalViewController?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///デリゲート委譲
        ADMINDAMMYVIEW.delegate = self
        ADMINDAMMYVIEW.nickNameItemView.delegate = self
        ADMINDAMMYVIEW.AboutMeItemView.delegate = self
        ADMINDAMMYVIEW.areaItemView.delegate = self
        ADMINDAMMYVIEW.birthItemView.delegate = self
        ADMINDAMMYVIEW.genderItemView.delegate = self
        ///半モーダルの初期設定
        FPC.delegate = self
        FPC.layout = CustomFloatingPanelLayout(initialState: .half, kind: .profileEdit)
        FPC.isRemovalInteractionEnabled  =  true
        FPC.backdropView.dismissalTapGestureRecognizer.isEnabled = true
    }
    
    override func loadView() {
        self.view = ADMINDAMMYVIEW
    }
    
}

///EXTENSION
extension AdminDammyProfileCreateViewController:AdminDammyProfileCreateViewDelegate,CropViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate{

    ///プロフィール画像タップ後の処理
    /// - Parameters:
    /// - Returns: none
    func profileImageButtonTappedDelegate() {
        ///アクションシートを表示してユーザーが選択した内容によって動作を切り替え
        createSheet(for: .Options(["画像を表示","画像を変更"], { index in
            switch index {
            case 0:
                self.SHOWIMAGEVIEWCONTROLLER.profileImage = self.ADMINDAMMYVIEW.profileImageButton.imageView?.image
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
        ///プロフィールイメージ投稿Model
            self.ADMINDAMMYVIEW.profileImageButton.setImage(image, for: .normal)
        ///cropViewControllerを閉じる
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    ///編集でキーボードが表示Or非表示になった際の処理
    func keyBoardObserverShowDelegate(Top: CGFloat) {
        FPC.move(to: .full, animated: true)
    }
    
    func keyBoardObserverHideDelegate() {
        FPC.move(to: .half, animated: true)
    }
    
    func buckButtonTappedDelegate() {
        self.dismiss(animated: true, completion: nil)
        self.slideOutToLeft()
    }
    
    func d_ProfileCreatedecisionButtontappedAction() {
        ADMINDAMMYVIEW.d_ProfileCreatedecisionButton.isEnabled = false
        RegisterDataChecking_Regist()
        ADMINDAMMYVIEW.d_ProfileCreatedecisionButton.isEnabled = true
    }
    
}
///EXTENSION[セミモーダルライブラリの適用]
extension AdminDammyProfileCreateViewController:FloatingPanelControllerDelegate,SemiModalTranslucentViewProtcol{
    func TranslucentViewTappedDelegate() {
        FPC.removePanelFromParent(animated: true)
    }
    
    // カスタマイズしたレイアウトに変更(デフォルトで使用する際は不要)
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        return CustomFloatingPanelLayout(initialState: .half, kind: .profileEdit)
        }

//    ///FPCをどの位置でRemoveするかを決める
//    func floatingPanel(_ fpc: FloatingPanelController, shouldRemoveAt location: CGPoint, with velocity: CGVector) -> Bool {
////        ///下にドラッグした瞬間にRemoveしたいので0と0
////        location.equalTo(CGPoint(x: 0, y: 0))
//        return true
//    }
    ///fpcを閉じる
    func removesemiModal(){
        
        FPC.removePanelFromParent(animated: true)
    }
       
    ///fpcが破棄された時に呼ばれる。（ちなみにユーザーが下にスワイプして画面からfpcが見えなくなっても呼ばれる）
    func floatingPanelWillRemove(_ fpc: FloatingPanelController) {
            ///後ろのブラービューを破棄
            SEMIMODALTRANSLUCENTVIEW.removeFromSuperview()
            self.tabBarController?.tabBar.isHidden = false
    }
}

///EXTENSION[プロフィール情報タップ時]
extension AdminDammyProfileCreateViewController:ProfileChildViewDelegate,AdminDammyProfileCreateModalViewControllerDelegateProtcol{
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
        SEMIMODALTRANSLUCENTVIEW.delegate = self
        switch tag{
        case 1:
            semiModalViewController = AdminDammyProfileCreateModalViewController(dicidedModal: .nickName)
        case 2:
            semiModalViewController = AdminDammyProfileCreateModalViewController(dicidedModal: .aboutMe)
        case 3:
            semiModalViewController = AdminDammyProfileCreateModalViewController(dicidedModal: .Area)
        case 4:
            semiModalViewController = AdminDammyProfileCreateModalViewController(dicidedModal: .birth)
        case 5:
            semiModalViewController = AdminDammyProfileCreateModalViewController(dicidedModal: .gender)
        default:break
        }
        FPC.set(contentViewController: semiModalViewController)
        semiModalViewController!.delegate = self
        FPC.addPanel(toParent: self, at: -1, animated: true, completion: nil)
    }
    
    func ButtonTappedActionChildDelegateAction(inputData: String, Item: DammyCreateModalItems) {
        switch Item {
        case .nickName:
            ADMINDAMMYVIEW.nickNameItemView.valueLabel.text = inputData
        case .aboutMe:
            ADMINDAMMYVIEW.AboutMeItemView.valueLabel.text = inputData
        case .Area:
            ADMINDAMMYVIEW.areaItemView.valueLabel.text = inputData
        case .birth:
            ADMINDAMMYVIEW.birthItemView.valueLabel.text = inputData
        case .gender:
            ADMINDAMMYVIEW.genderItemView.valueLabel.text = inputData
        }
        ///FPC破棄
        FPC.removePanelFromParent(animated: true)
    }
}

extension AdminDammyProfileCreateViewController {
    func RegisterDataChecking_Regist() {
        
        let warningAction = {
            createSheet(for: .Retry(title: "いづけかの値がNullか正しく入力されていません。(画像含む)"), SelfViewController: self)
        }
        
        let registerFailedAction = {
            createSheet(for: .Retry(title: "初期登録に失敗しました。"), SelfViewController: self)
        }
        
        let registCompletedAction = {
            createSheet(for: .Retry(title: "すべての登録に成功しました。"), SelfViewController: self)
        }
        
        guard let nickname = ADMINDAMMYVIEW.nickNameItemView.valueLabel.text,
              let aboutMe = ADMINDAMMYVIEW.AboutMeItemView.valueLabel.text,
              let Area = ADMINDAMMYVIEW.areaItemView.valueLabel.text,
              let birth = ADMINDAMMYVIEW.birthItemView.valueLabel.text,
              let gender = ADMINDAMMYVIEW.genderItemView.valueLabel.text else 
        {
            warningAction()
            return
        }
        
        if nickname == "" || aboutMe == "" || Area == "" || birth == "" || gender == "" {
            warningAction()
            return
        }
        
        guard let IntGender = Int(gender),let IntBirth = Int(birth) else {
            warningAction()
            return
        }
        
        guard let Image = ADMINDAMMYVIEW.profileImageButton.imageView?.image else {
            warningAction()
            return
        }
        //ダミー用UID生成
        var randomNumString: String
        let randomNum = arc4random_uniform(UInt32(pow(10, Double(6))))
        randomNumString = String(format: "%0\(6)d", randomNum)

        //ダミー用アップデートデータ作成
        let updateObject = ProfileInfoLocalObject()
        updateObject.lcl_UID = "\(randomNumString)Yd7MNepBxzSc0p7bpp3LjcwSl1h2"
        updateObject.lcl_NickName = nickname
        updateObject.lcl_Area = Area
        updateObject.lcl_AboutMeMassage = aboutMe
        updateObject.lcl_Age = IntBirth
        updateObject.lcl_Sex = IntGender
        
        //ダミーデータ登録(Yd7MNepBxzSc0p7bpp3LjcwSl1h2はダミー共通UID)
        REGISTERHOSTSETTER.userInfoRegister(callback: { result in
            if case.Success(let successMessage) = result {
                self.CONTENTSHOSTSETTER.contentOfFIRStorageUpload(callback: { uploadedImage in
                    guard let uploadedImage = uploadedImage else {
                        //画像送信に失敗した場合は警告出して登録したメンバーのUIDを削除
                        registerFailedAction()
                        self.ADMINHOSTSETTER.memberUIDDeleate(UID: "\(randomNumString)Yd7MNepBxzSc0p7bpp3LjcwSl1h2")
                        return
                    }
                    //成功
                    registCompletedAction()
                    
                    self.allViewDataClear()
                    return
                }, UIimagedata: self.ADMINDAMMYVIEW.profileImageButton.imageView!, UID: updateObject.lcl_UID!)
            }else if case.failure(let successMessage) = result {
                registerFailedAction()
            }
        }, USER: updateObject, uid: updateObject.lcl_UID!, signUpFlg: .dammy)
    }
    
    func allViewDataClear() {
        ADMINDAMMYVIEW.nickNameItemView.valueLabel.text = ""
        ADMINDAMMYVIEW.AboutMeItemView.valueLabel.text = ""
        ADMINDAMMYVIEW.areaItemView.valueLabel.text = ""
        ADMINDAMMYVIEW.birthItemView.valueLabel.text = ""
        ADMINDAMMYVIEW.genderItemView.valueLabel.text = ""
        ADMINDAMMYVIEW.profileImageButton.imageView?.image = nil
    }
    
}
