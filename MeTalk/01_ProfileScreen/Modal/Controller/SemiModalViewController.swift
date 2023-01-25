//
//  SemiModalViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/12.
//

import Foundation
import UIKit
import Firebase

protocol SemiModalViewControllerProtcol:AnyObject{
    func ButtonTappedActionChildDelegateAction()
}

class SemiModalViewController:UIViewController,UITextFieldDelegate{
    
    ///インスタンス化(View)
    var VIEW:ModalBaseView?
    
//    let nickNameTextFieldModalView = NickNameTextFieldModalView()
//    let aboutMeTextFieldModalView = AboutMeTextFieldModalView()
//    let areaPickerModalView = AreaPickerModalView()
//    let agePickerModalView = AgePickerModalView()
    ///インスタンス化(Model)
    let userDataManageData = UserDataManage()
    let modalImageData = ModalImageData()
    let uid = Auth.auth().currentUser?.uid
    ///Viewフラグ判断変数
    var dicidedModal:ModalItems
//    {
//        get {
//            self.VIEW = ModalBaseView(ModalItems:self.dicidedModal, frame: self.view.frame)
//        }
//    }
    
    ///デリゲート変数
    weak var delegate:SemiModalViewControllerProtcol?
    
    init(dicidedModal:ModalItems){
        self.dicidedModal = dicidedModal
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ///画面共通処理
        self.VIEW = ModalBaseView(ModalItems:self.dicidedModal, frame: self.view.frame)
        guard let VIEW = VIEW else {
            ///ここで前の画面もどす処理を入れてもいいかもしれない
            return
        }
        ///デリゲート委譲
        VIEW.delegate = self
        ///クローズ画像データをセット
        VIEW.CloseModalButton.setImage(self.modalImageData.closedImage, for: .normal)
        
        ///決定された各編集ボタンによって処理
        switch dicidedModal {
        ///ニックネーム編集
        case .nickName:
            ///自身のView適用（ニックネーム)
            self.view = VIEW
            ///現在のユーザー名をローカルDBから取得
            userProfileDatalocalGet(callback: { document in
                VIEW.itemTitleLabel.text = "アイテムタイトルラベル"
                ///ユーザー名情報をテキストフィールドにセット
                VIEW.itemTextField.text = document["nickname"] as? String
            }, UID: uid!, ViewFLAG: 1)

            ///オブザーバー（テキストフィールドの文字が変更されたタイミング）
            NotificationCenter.default.addObserver(self,
              selector: #selector(textFieldDidChange(notification:)),
              name: UITextField.textDidChangeNotification,
              object: VIEW.itemTextField)
        case .aboutMe:
            self.view = VIEW
            ///現在のひとことをローカルDBから取得
            userProfileDatalocalGet(callback: { document in
                ///ユーザー名情報をテキストフィールドにセット
                VIEW.itemTextField.text = document["aboutMeMassage"] as? String
            }, UID: uid!, ViewFLAG: 1)
            ///オブザーバー（テキストフィールドの文字が変更されたタイミング）
            NotificationCenter.default.addObserver(self,
              selector: #selector(textFieldDidChange(notification:)),
              name: UITextField.textDidChangeNotification,
              object: VIEW.itemTextField)
        case .Age:
            self.view = VIEW
            ///現在の年齢をローカルDBから取得
            userProfileDatalocalGet(callback: { document in
                var agedata = document["age"] as? Int
                if agedata == 0 {
                    VIEW.itemTextField.text = "未設定"
                } else {
                    ///年齢情報をテキストフィールドにセット
                    VIEW.itemTextField.text = String(agedata!)
                }
            }, UID: uid!, ViewFLAG: 1)
        case .Area:
            self.view = VIEW
            ///現在の住まいをローカルDBから取得
            userProfileDatalocalGet(callback: { document in
                ///住まいをテキストフィールドにセット
                VIEW.itemTextField.text = document["area"] as? String
            }, UID: uid!, ViewFLAG: 1)
        }
        
//        if viewFlag == 1 {
//
//            ///★viewFlg2はひとこと★
//        } else if viewFlag == 2{
//
//            self.view = aboutMeTextFieldModalView
//            ///デリゲート委譲
//            aboutMeTextFieldModalView.delegate = self
//            aboutMeTextFieldModalView.itemTextField.delegate = self
//            ///現在のひとことをローカルDBから取得
//            userProfileDatalocalGet(callback: { document in
//                ///ユーザー名情報をテキストフィールドにセット
//                self.aboutMeTextFieldModalView.itemTextField.text = document["aboutMeMassage"] as? String
//            }, UID: uid!, ViewFLAG: 1)
//            ///クローズ画像データをセット
//            self.aboutMeTextFieldModalView.CloseModalButton.setImage(self.modalImageData.closedImage, for: .normal)
//            ///オブザーバー（テキストフィールドの文字が変更されたタイミング）
//            NotificationCenter.default.addObserver(self,
//              selector: #selector(textFieldDidChange(notification:)),
//              name: UITextField.textDidChangeNotification,
//              object: aboutMeTextFieldModalView.itemTextField)
//            ///★viewFlg3は年齢★
//        } else if viewFlag == 3{
//
//            self.view = agePickerModalView
//            ///デリゲート委譲
//            agePickerModalView.delegate = self
//            ///現在の年齢をローカルDBから取得
//            userProfileDatalocalGet(callback: { document in
//                var agedata = document["age"] as? Int
//                if agedata == 0 {
//                    self.agePickerModalView.itemTextField.text = "未設定"
//                } else {
//                    ///年齢情報をテキストフィールドにセット
//                    self.agePickerModalView.itemTextField.text = String(agedata!)
//                }
//
//            }, UID: uid!, ViewFLAG: 1)
//            ///クローズ画像データをセット
//            self.agePickerModalView.CloseModalButton.setImage(self.modalImageData.closedImage, for: .normal)
//
//            ///★viewFlg4は住まい★
//        } else if viewFlag == 4{
//            self.view = areaPickerModalView
//            ///デリゲート委譲
//            areaPickerModalView.delegate = self
//            ///現在の住まいをローカルDBから取得
//            userProfileDatalocalGet(callback: { document in
//                ///住まいをテキストフィールドにセット
//                self.areaPickerModalView.itemTextField.text = document["area"] as? String
//            }, UID: uid!, ViewFLAG: 1)
//            ///クローズ画像データをセット
//            self.areaPickerModalView.CloseModalButton.setImage(self.modalImageData.closedImage, for: .normal)
//        }
    }
    ///オブザーバー破棄
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

///★★★★★★★★★★★★★★★★★★★★★★★(主にviewFlag == 1と2の画面処理で使用)★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
//文字制限を行うオブザーバー処理
extension SemiModalViewController{
    ///    ///オブザーバー処理
    /// - Parameters:
    ///   - notification: オブザーバーから渡されたオブジェクト（ここではテキストフィールドに関するもの）
    /// - Returns: none
    @objc func textFieldDidChange(notification: NSNotification) {
        ///画面共通処理
        guard let VIEW = VIEW else {
            ///ここで前の画面もどす処理を入れてもいいかもしれない
            return
        }
        ///Selecterで受け取ったオブジェクトをUITextFieldに変換処理
        let textField = notification.object as! UITextField
        
        ///テキストが入っていない場合
        guard let text = textField.text else {
            ///決定ボタンを無効化してReturn
            VIEW.decisionButton.isEnabled = false
            VIEW.decisionButton.backgroundColor = .gray
            return
        }
        ///入っている場合決定ボタンを有効化
        VIEW.decisionButton.isEnabled = true
        VIEW.decisionButton.backgroundColor = .orange

        switch self.dicidedModal {
        case .nickName:
            ///文字制限処理(10文字)
            if textField.markedTextRange == nil && text.count > 10 {
                    textField.text = text.prefix(10).description
            }
        case .aboutMe:
            ///文字制限処理(30文字)
            if let text = textField.text {
                if textField.markedTextRange == nil && text.count > 30 {
                        textField.text = text.prefix(30).description
                }
            }
        default:
            preconditionFailure("出身地と年齢のテキストが変更できるようになっています。コード修正してください")
        }
        
        
        
////        ///ボタン活性化チェック処理
////        textFieldBrankCheck_ButtonActive(tag: textField.tag)
//        if textField.tag == 1{
//            ///nickNameModalView文字制限処理(10文字)
//            if let text = textField.text {
//                if textField.markedTextRange == nil && text.count > 10 {
//                        textField.text = text.prefix(10).description
//                }
//            }
//        } else if textField.tag == 2 {
//            ///aboutMeModalView文字制限処理(10文字)
//            if let text = textField.text {
//                if textField.markedTextRange == nil && text.count > 30 {
//                        textField.text = text.prefix(30).description
//                }
//            }
//        }
    }
}
/////ボタン活性化処理行うオブザーバー処理
//extension SemiModalViewController{
//    ///    /// ボタン活性化及びテキスト入力チェック
//    /// - Parameters:
//    /// - Returns: none
//    func textFieldBrankCheck_ButtonActive(tag:Int){
//        if tag == 1 {
//            if nickNameTextFieldModalView.itemTextField.text != ""{
//                nickNameTextFieldModalView.decisionButton.isEnabled = true
//                nickNameTextFieldModalView.decisionButton.backgroundColor = .orange
//            } else {
//                nickNameTextFieldModalView.decisionButton.isEnabled = false
//                nickNameTextFieldModalView.decisionButton.backgroundColor = .gray
//            }
//        } else if tag == 2 {
//            if aboutMeTextFieldModalView.itemTextField.text != ""{
//                aboutMeTextFieldModalView.decisionButton.isEnabled = true
//                aboutMeTextFieldModalView.decisionButton.backgroundColor = .orange
//            } else {
//                aboutMeTextFieldModalView.decisionButton.isEnabled = false
//                aboutMeTextFieldModalView.decisionButton.backgroundColor = .gray
//            }
//        }
//    }
//}

//※キーボードオプション※
extension SemiModalViewController{
    
    ///    ///リターンボタンを押下したらキーボードがしまわれる処理
    /// - Parameters:
    /// - Returns: none
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    ///    /// 空白の部分をタッチしたらキーボードがしまわれる処理
    /// - Parameters:
    /// - Returns: none
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ///画面共通処理
        guard let VIEW = VIEW else {
            ///ここで前の画面もどす処理を入れてもいいかもしれない
            return
        }
        VIEW.itemTextField.endEditing(true)
        VIEW.itemTextField.endEditing(true)
    }

}

///ボタンを押下した時のデリゲート関数
extension SemiModalViewController:ModalViewDelegateProtcol{
    ///決定ボタン押下　view: NickNameTextFieldModalView
    func dicisionButtonTappedAction(button: UIButton, objects: ModalItems) {
        print("決定ボタンが押されました")
    }
    
    func closeModalButttonClickedButtonTappedAction(button: UIButton, view: ModalBaseView) {
        self.delegate?.ButtonTappedActionChildDelegateAction()
    }
    
    func dicisionButtonTappedAction(button: UIButton, view: NickNameTextFieldModalView) {
        ///入力したユーザー名をUpload
        userDataManageData.userInfoDataUpload(userData: view.itemTextField.text, dataFlg: 1, UID: uid)
        self.delegate?.ButtonTappedActionChildDelegateAction()
    }
    ///クローズボタン画像押下　view: NickNameTextFieldModalView
    func closeButtonTappedAction(button: UIButton, view: NickNameTextFieldModalView) {
        self.delegate?.ButtonTappedActionChildDelegateAction()
    }
    ///決定ボタン押下　view: AboutMeTextFieldModalView
    func dicisionButtonTappedAction(button: UIButton, view: AboutMeTextFieldModalView) {
        ///入力したユーザー名をUpload
        userDataManageData.userInfoDataUpload(userData: view.itemTextField.text, dataFlg: 2, UID: uid)
        self.delegate?.ButtonTappedActionChildDelegateAction()
    }
    ///クローズボタン画像押下　view: AboutMeTextFieldModalView
    func closeButtonTappedAction(button: UIButton, view: AboutMeTextFieldModalView) {
        self.delegate?.ButtonTappedActionChildDelegateAction()
    }
    ///決定ボタン押下　view: AgePickerModalView
    func dicisionButtonTappedAction(button: UIButton, view: AgePickerModalView) {
        ///入力した年齢をUpload
        ///（年齢をIntに変換）
        guard let AgeTypeString = view.itemTextField.text else {
            print("年齢が取得もしくはキャストできませんでした")
            return
        }
        guard let AgeTypeInt = Int(AgeTypeString) else {
            print("年齢が取得もしくはキャストできませんでした")
            return
        }
        print(AgeTypeInt)
        userDataManageData.userInfoDataUpload(userData: AgeTypeInt, dataFlg: 3, UID: uid)
        self.delegate?.ButtonTappedActionChildDelegateAction()
    }
    ///クローズボタン画像押下　view: AgePickerModalView
    func closeButtonTappedAction(button: UIButton, view: AgePickerModalView) {
        self.delegate?.ButtonTappedActionChildDelegateAction()
    }
    ///決定ボタン押下　view: AreaPickerModalView
    func dicisionButtonTappedAction(button: UIButton, view: AreaPickerModalView) {
        ///入力した出身地をUpload
        userDataManageData.userInfoDataUpload(userData: view.itemTextField.text, dataFlg: 4, UID: uid)
        self.delegate?.ButtonTappedActionChildDelegateAction()
    }
    ///クローズボタン画像押下　view: AreaPickerModalView
    func closeButtonTappedAction(button: UIButton, view: AreaPickerModalView) {
        self.delegate?.ButtonTappedActionChildDelegateAction()
    }
}
///★★★★★★★★★★★★★★★★★★★★★★★(主にviewFlag == 1と2の画面処理で使用)★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
