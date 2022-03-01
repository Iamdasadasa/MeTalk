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

class MeTalkProfileViewController:UIViewController{

    
    ///認証状態をリッスンする変数定義
    var handle:AuthStateDidChangeListenerHandle?
    ///UID格納変数
    var UID:String?
    ///カメラピッカーの定義
    let picker = UIImagePickerController()
    ///インスタンス化(Controller)
    var contentVC:UIViewController?
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
//        ///半モーダルの初期設定
//        contentVC = SemiModalViewController()
//        fpc.set(contentViewController: contentVC)
        fpc.delegate = self
        fpc.layout = CustomFloatingPanelLayout()
        fpc.isRemovalInteractionEnabled  =  true
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
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
        picker.delegate = self
        ///強制的にアルバム
        picker.sourceType = .photoLibrary
        ///カメラピッカー表示
        self.present(picker, animated: true, completion: nil)
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
        ///pickerが取得した画像データをUIimageに変換して格納
        if let pickerImage = info[.originalImage] as? UIImage{
            ///UIimageViewをModelインスタンス先で圧縮するためにImageviewをインスタンス化
            let UIimageView = UIImageView()
            UIimageView.image = pickerImage
            ///プロフィールイメージ投稿Model
            userDataManagedData.contentOfFIRStorageUpload(callback: { pressureImage in
                self.meTalkProfileView.profileImageButton.setImage(pressureImage, for: .normal)
            }, UIimagedata: UIimageView)
            ///閉じる
            self.dismiss(animated: true, completion: nil)
        }
    }
    ///開発用　サインアウトボタンタップ時の挙動
    func signoutButtonTappedDelegate() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("SignOut Error: %@", signOutError)
        }
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
            print("うんちがぶり")
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

    }
    
}

///セミモーダルライブラリの適用
extension MeTalkProfileViewController:FloatingPanelControllerDelegate{
    // カスタマイズしたレイアウトに変更(デフォルトで使用する際は不要)
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        return CustomFloatingPanelLayout()
    }
    ///モーダルが特定の位置に来たときに処理を行う
    func floatingPanelWillEndDragging(_ fpc: FloatingPanelController, withVelocity velocity: CGPoint, targetState: UnsafeMutablePointer<FloatingPanelState>) {

        ///三段階中の.tipの高さにきたら処理
        if targetState.pointee == .half{
            removesemiModal()
            ///FpcのViewを破棄
            self.fpc.view.removeFromSuperview()
        }
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

///SemiModalViewControllerからのデリゲート処理で、二ついれこになっている。大元のデリゲート処理は
///ここのViewControllerであるMeTalkProfileViewController。さらにそこからfpcで追加したSemiModalViewController。
///さらにSemiModalViewControllerのViewで追加した各Viewの決定ボタンが大元の発火処理になっている。
///fpcを取り除く処理をしなくてはならないためにsemiModalViewControllerからさらにこのコントローラにデリゲートして処理を行なっている。
extension MeTalkProfileViewController:SemiModalViewControllerProtcol{
    func ButtonTappedActionChildDelegateAction() {
        fpc.removePanelFromParent(animated: true)
    }
}
