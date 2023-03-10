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
    
    ///インスタンス化(Model)
    let userDataManageData = UserDataManage()
    let modalImageData = ModalImageData()
    let uid = Auth.auth().currentUser?.uid
    ///Viewフラグ判断変数
    var dicidedModal:ModalItems
    
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
                ///ユーザー名情報をテキストフィールドにセット
                VIEW.itemTextField.text = document["nickname"] as? String
            }, UID: uid!, hostiong: .hosting, ViewController: self)

            ///オブザーバー（テキストフィールドの文字が変更されたタイミング）
            NotificationCenter.default.addObserver(self,
              selector: #selector(textFieldDidChange(notification:)),
              name: UITextField.textDidChangeNotification,
              object: VIEW.itemTextField)
        ///ひとこと編集
        case .aboutMe:
            self.view = VIEW
            ///現在のひとことをローカルDBから取得
            userProfileDatalocalGet(callback: { document in
                ///ひとことをテキストフィールドにセット
                VIEW.itemTextField.text = document["aboutMeMassage"] as? String
            }, UID: uid!, hostiong: .hosting, ViewController: self)
            ///オブザーバー（テキストフィールドの文字が変更されたタイミング）
            NotificationCenter.default.addObserver(self,
              selector: #selector(textFieldDidChange(notification:)),
              name: UITextField.textDidChangeNotification,
              object: VIEW.itemTextField)
        ///年齢編集
        case .Age:
            self.view = VIEW
            
            ///現在の年齢をローカルDBから取得
            userProfileDatalocalGet(callback: { document in
                let agedata = document["age"] as? Int
                if agedata == 0 {
                    VIEW.itemTextField.text = "未設定"
                } else {
                    ///年齢情報をテキストフィールドにセット
                    VIEW.itemTextField.text = String(agedata!)
                }
            }, UID: uid!, hostiong: .hosting, ViewController: self)
        ///住まい編集
        case .Area:
            self.view = VIEW

            ///現在の住まいをローカルDBから取得
            userProfileDatalocalGet(callback: { document in
                ///住まいをテキストフィールドにセット
                VIEW.itemTextField.text = document["area"] as? String
            }, UID: uid!, hostiong: .hosting, ViewController: self)
        }
    }
    ///オブザーバー破棄
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//文字制限を行うオブザーバー処理
extension SemiModalViewController{
    ///    ///オブザーバー処理
    /// - Parameters:
    ///   - notification: オブザーバーから渡されたオブジェクト（ここではテキストフィールドに関するもの）
    /// - Returns: none
    @objc func textFieldDidChange(notification: NSNotification) {
        ///画面共通処理
        guard let VIEW = VIEW else {
            return
        }
        ///Selecterで受け取ったオブジェクトをUITextFieldに変換処理
        let textField = notification.object as! UITextField
        
        ///テキストがNilになることはないが念の為オプショナル対応
        guard let text = textField.text else {
            return
        }
        ///テキストが入っていない場合
        if text.count == 0 {
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
        ///画面共通処理
        guard let VIEW = VIEW else {
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
        ///画面共通処理
        guard let VIEW = VIEW else {
            return
        }
        ///データ代入
        let data = VIEW.itemTextField.text
        ///年齢だった場合
        if objects == .Age {
            ///（年齢をIntに変換）
            guard let AgeTypeString = data else {
                print("年齢が取得もしくはキャストできませんでした")
                return
            }
            guard let AgeTypeInt = Int(AgeTypeString) else {
                print("年齢が取得もしくはキャストできませんでした")
                return
            }
            ///入力したユーザーデータをアップデート
            userDataManageData.userInfoDataUpload(userData: AgeTypeInt, dataFlg: objects, UID: uid, ViewController: self)
        }
        
        ///入力したユーザーデータをアップデート
        userDataManageData.userInfoDataUpload(userData: data, dataFlg: objects, UID: uid, ViewController: self)
        self.delegate?.ButtonTappedActionChildDelegateAction()
    }
    
    func closeModalButttonClickedButtonTappedAction(button: UIButton, view: ModalBaseView) {
        ///クローズ処理
        self.delegate?.ButtonTappedActionChildDelegateAction()
    }
}
