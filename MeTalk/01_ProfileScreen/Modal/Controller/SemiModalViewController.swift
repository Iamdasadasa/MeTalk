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
    let PROFILEHOSTING = profileHosting()
    let modalImageData = ModalImageData()
    let uid = Auth.auth().currentUser?.uid
    var ProfileData = profileInfoLocal()
    ///プロフィール初期値
    let STR = {(CS:USERINFODEFAULTVALUE) -> String in
        return CS.StrObjec
    }
    let INT = {(CS:USERINFODEFAULTVALUE) -> Int in
        return CS.NumObjec
    }
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
        
        ///プロフィールデータ取得
        var LOCALDATA = localProfileDataStruct(UID: uid!)
        LOCALDATA.userProfileDatalocalGet { profileInfoLocal, result in
            if result == .localNoting {
                hostingProfileDataGetter()
            }
            self.ProfileData = profileInfoLocal
        }
        ///サーバー通信してデータ取得
        func hostingProfileDataGetter() {
            var hosting = profileHosting()
            hosting.FireStoreProfileDataGetter(callback: { info, err in
                if err != nil {
                    print("サーバにデータが存在していないのに初期以外の画面にいるのはありえない")
                    return
                }
                self.ProfileData = info
            }, UID: uid!)
        }

        
        ///決定された各編集ボタンによって処理
        switch dicidedModal {
        ///ニックネーム編集
        case .nickName:
            ///自身のView適用（ニックネーム)
            self.view = VIEW
            
            ///ユーザー名情報をテキストフィールドにセット
            VIEW.itemTextField.text = ProfileData.lcl_NickName

            ///オブザーバー（テキストフィールドの文字が変更されたタイミング）
            NotificationCenter.default.addObserver(self,
              selector: #selector(textFieldDidChange(notification:)),
              name: UITextField.textDidChangeNotification,
              object: VIEW.itemTextField)
        ///ひとこと編集
        case .aboutMe:
            self.view = VIEW
            ///ひとこと情報をテキストフィールドにセット
            VIEW.itemTextField.text = ProfileData.lcl_AboutMeMassage
            ///オブザーバー（テキストフィールドの文字が変更されたタイミング）
            NotificationCenter.default.addObserver(self,
              selector: #selector(textFieldDidChange(notification:)),
              name: UITextField.textDidChangeNotification,
              object: VIEW.itemTextField)
        ///年齢編集
        case .Age:
            self.view = VIEW
            ///年齢情報をテキストフィールドにセット
            let agedata = ProfileData.lcl_Age
                if agedata == 0 {
                    VIEW.itemTextField.text = "未設定"
                } else {
                    ///年齢情報をテキストフィールドにセット
                    VIEW.itemTextField.text = String(agedata)
                }
        ///住まい編集
        case .Area:
            self.view = VIEW

            ///ひとこと情報をテキストフィールドにセット
            VIEW.itemTextField.text = ProfileData.lcl_Area
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
    func dicisionButtonTappedAction(button: UIButton, objects: updateKind) {
        ///画面共通処理
        guard let VIEW = VIEW else {
            return
        }
        guard let uid = uid else {
            return
        }
        ///データ代入
        let data = VIEW.itemTextField.text
        var updateData:profileInfoLocal = profileInfoLocal()
        updateData.lcl_UID = uid
        ///ローカルデータ登録
        switch objects {
        case .nickName:
            updateData.lcl_NickName = data
        case .age:
            guard let data = data else {
                return
            }
            guard let age = Int(data) else {
                return
            }
            updateData.lcl_Age = age
        case .aboutMe:
            updateData.lcl_AboutMeMassage = data
        case .area:
            updateData.lcl_Area = data
        }
        ///サーバデータ登録
        PROFILEHOSTING.userDataUpdateManager(KIND: objects, Data: updateData)
        ///ローカルデータ登録
        let LOCAL = localProfileDataStruct(updateObject: updateData, UID: updateData.lcl_UID!)
        if LOCAL.userProfileLocalDataExtraRegist() == .localNoting {
            let action = actionSheets(dicidedOrOkOnlyTitle: "データが見つかりませんでした", message: "データが見つからないため入力されたデータ以外はデフォルトの値が保存されます", buttonMessage: "OK")
            action.okOnlyAction(callback: { resukt in
                return
            }, SelfViewController: self)
        }

        self.delegate?.ButtonTappedActionChildDelegateAction()
    }
    
    func closeModalButttonClickedButtonTappedAction(button: UIButton, view: ModalBaseView) {
        ///クローズ処理
        self.delegate?.ButtonTappedActionChildDelegateAction()
    }
}
