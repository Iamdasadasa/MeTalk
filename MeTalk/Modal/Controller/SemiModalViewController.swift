//
//  SemiModalViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/12.
//

import Foundation
import UIKit


class SemiModalViewController:UIViewController,UITextFieldDelegate,NickNameTextFieldModalViewDelegateProtcol,AboutMeTextFieldModalViewDelegateProtcol{
    ///インスタンス化(View)
    let nickNameTextFieldModalView = NickNameTextFieldModalView()
    let aboutMeTextFieldModalView = AboutMeTextFieldModalView()
    let pickerModalView = PickerModalView()
    ///インスタンス化(Model)
    let userDataManageData = UserDataManagedData()
    let modalImageData = ModalImageData()
    ///Viewフラグ判断変数
    var viewFlag:Int
    
    init(viewFlg:Int){
        self.viewFlag = viewFlg
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///このViewkcontrollerが呼ばれる際にView Flgをイニシャライザしている。その値を判断して適切なViewをセット
        ///★viewFlg1はニックネーム★
        if viewFlag == 1 {
            self.view = nickNameTextFieldModalView
            ///デリゲート委譲
            nickNameTextFieldModalView.delegate = self
            nickNameTextFieldModalView.itemTextField.delegate = self
            ///現在のユーザー名を取得
            userDataManageData.userInfoDataGet(callback: { userInfoData in
                guard let userInfoData = userInfoData else {
                    print("ユーザーデータが取得できませんでした。SemiModalViewController")
                    return
                }
                ///ユーザー名情報をテキストフィールドにセット
                self.nickNameTextFieldModalView.itemTextField.text = userInfoData["nickname"] as? String
                ///クローズ画像データをセット
                self.nickNameTextFieldModalView.CloseModalButton.setImage(self.modalImageData.closedImage, for: .normal)
            })
            ///オブザーバー（テキストフィールドの文字が変更されたタイミング）
            NotificationCenter.default.addObserver(self,
              selector: #selector(textFieldDidChange(notification:)),
              name: UITextField.textDidChangeNotification,
              object: nickNameTextFieldModalView.itemTextField)
            ///★viewFlg2はひとこと★
        } else if viewFlag == 2{
            
            self.view = aboutMeTextFieldModalView
            ///デリゲート委譲
            aboutMeTextFieldModalView.delegate = self
            aboutMeTextFieldModalView.itemTextField.delegate = self
            ///現在のひとことを取得
            userDataManageData.userInfoDataGet(callback: { userInfoData in
                guard let userInfoData = userInfoData else {
                    print("ユーザーデータが取得できませんでした。SemiModalViewController")
                    return
                }
                ///ひとことをテキストフィールドにセット
                self.aboutMeTextFieldModalView.itemTextField.text = userInfoData["aboutMeMassage"] as? String
                ///クローズ画像データをセット
                self.aboutMeTextFieldModalView.CloseModalButton.setImage(self.modalImageData.closedImage, for: .normal)
            })
            ///オブザーバー（テキストフィールドの文字が変更されたタイミング）
            NotificationCenter.default.addObserver(self,
              selector: #selector(textFieldDidChange(notification:)),
              name: UITextField.textDidChangeNotification,
              object: aboutMeTextFieldModalView.itemTextField)
            ///★viewFlg3は住まい★
        } else if viewFlag == 3{
            self.view = pickerModalView
            
            ///クローズ画像データをセット
            self.pickerModalView.CloseModalButton.setImage(self.modalImageData.closedImage, for: .normal)
        }
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
        ///Selecterで受け取ったオブジェクトをUITextFieldに変換処理
        let textField = notification.object as! UITextField
        ///ボタン活性化チェック処理
        textFieldBrankCheck_ButtonActive(tag: textField.tag)
        if textField.tag == 1{
            ///nickNameModalView文字制限処理(10文字)
            if let text = textField.text {
                if textField.markedTextRange == nil && text.count > 10 {
                        textField.text = text.prefix(10).description
                }
            }
        } else if textField.tag == 2 {
            ///aboutMeModalView文字制限処理(10文字)
            if let text = textField.text {
                if textField.markedTextRange == nil && text.count > 30 {
                        textField.text = text.prefix(30).description
                }
            }
        }
    }
}
///ボタン活性化処理行うオブザーバー処理
extension SemiModalViewController{
    ///    /// ボタン活性化及びテキスト入力チェック
    /// - Parameters:
    /// - Returns: none
    func textFieldBrankCheck_ButtonActive(tag:Int){
        if tag == 1 {
            if nickNameTextFieldModalView.itemTextField.text != ""{
                nickNameTextFieldModalView.decisionButton.isEnabled = true
                nickNameTextFieldModalView.decisionButton.backgroundColor = .orange
            } else {
                nickNameTextFieldModalView.decisionButton.isEnabled = false
                nickNameTextFieldModalView.decisionButton.backgroundColor = .gray
            }
        } else if tag == 2 {
            if aboutMeTextFieldModalView.itemTextField.text != ""{
                aboutMeTextFieldModalView.decisionButton.isEnabled = true
                aboutMeTextFieldModalView.decisionButton.backgroundColor = .orange
            } else {
                aboutMeTextFieldModalView.decisionButton.isEnabled = false
                aboutMeTextFieldModalView.decisionButton.backgroundColor = .gray
            }
        }
    }
}

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
        nickNameTextFieldModalView.itemTextField.endEditing(true)
        aboutMeTextFieldModalView.itemTextField.endEditing(true)
    }

}

///ボタンを押下した時のデリゲート関数
extension SemiModalViewController{
    ///決定ボタン押下　view: NickNameTextFieldModalView
    func dicisionButtonTappedAction(button: UIButton, view: NickNameTextFieldModalView) {
        ///入力したユーザー名をUpload
        userDataManageData.userInfoDataUpload(userData: view.itemTextField.text, dataFlg: 1)
        self.dismiss(animated: true, completion: nil)
    }
    ///クローズボタン画像押下　view: NickNameTextFieldModalView
    func closeButtonTappedAction(button: UIButton, view: NickNameTextFieldModalView) {
        self.dismiss(animated: true, completion: nil)
    }
    ///決定ボタン押下　view: AboutMeTextFieldModalView
    func dicisionButtonTappedAction(button: UIButton, view: AboutMeTextFieldModalView) {
        ///入力したユーザー名をUpload
        userDataManageData.userInfoDataUpload(userData: view.itemTextField.text, dataFlg: 2)
        self.dismiss(animated: true, completion: nil)
    }
    ///クローズボタン画像押下　view: AboutMeTextFieldModalView
    func closeButtonTappedAction(button: UIButton, view: AboutMeTextFieldModalView) {
        self.dismiss(animated: true, completion: nil)
    }
}
///★★★★★★★★★★★★★★★★★★★★★★★(主にviewFlag == 1と2の画面処理で使用)★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
