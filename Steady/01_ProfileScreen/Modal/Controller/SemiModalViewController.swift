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
    let PROFILESETTER = ProfileHostSetter()
    let PROFILEGETTER = ProfileHostGetter()
    let modalImageData = ModalImageData()
    var SELFPROFILE:RequiredProfileInfoLocalData
    ///Viewフラグ判断変数
    var dicidedModal:ModalItems
    ///デリゲート変数
    weak var delegate:SemiModalViewControllerProtcol?

    init(dicidedModal:ModalItems,SELFPROFILE:RequiredProfileInfoLocalData){
        self.SELFPROFILE = SELFPROFILE
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
        ///文字数チェック
        textCounterDecisionButtonEnable()
        ///決定された各編集ボタンによって処理
        switch dicidedModal {
        ///ニックネーム編集
        case .nickName:
            ///自身のView適用（ニックネーム)
            self.view = VIEW
            
            ///ユーザー名情報をテキストフィールドにセット
            VIEW.itemTextField.text = SELFPROFILE.Required_NickName

            ///オブザーバー（テキストフィールドの文字が変更されたタイミング）
            NotificationCenter.default.addObserver(self,
              selector: #selector(textFieldDidChange(notification:)),
              name: UITextField.textDidChangeNotification,
              object: VIEW.itemTextField)
        ///ひとこと編集
        case .aboutMe:
            self.view = VIEW
            ///ひとこと情報をテキストフィールドにセット
            VIEW.itemTextField.text = SELFPROFILE.Required_AboutMeMassage
            
            ///オブザーバー（テキストフィールドの文字が変更されたタイミング）
            NotificationCenter.default.addObserver(self,
              selector: #selector(textFieldDidChange(notification:)),
              name: UITextField.textDidChangeNotification,
              object: VIEW.itemTextField)
        ///住まい編集
        case .Area:
            self.view = VIEW

            ///ひとこと情報をテキストフィールドにセット
            VIEW.itemTextField.text = SELFPROFILE.Required_Area
        }
    }
    ///テキストが一0文字だった場合は決定ボタン無効化
    func textCounterDecisionButtonEnable() {
        if VIEW?.itemTextField.text?.count == 0{
            VIEW?.decisionButton.isEnabled = false
            VIEW?.decisionButton.backgroundColor = .gray
            VIEW?.decisionButton.setTitleColor(UIColor.white, for: .normal)
        } else {
            VIEW?.decisionButton.isEnabled = true
            VIEW?.decisionButton.backgroundColor = .white
            VIEW?.decisionButton.setTitleColor(UIColor.gray, for: .normal)
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
        ///テキストチェック
        textCounterDecisionButtonEnable()

        switch self.dicidedModal {
        case .nickName:
            ///文字制限処理(10文字)
            if textField.markedTextRange == nil && text.count > 5 {
                    textField.text = text.prefix(5).description
            }
        case .aboutMe:
            ///文字制限処理(30文字)
            if let text = textField.text {
                if textField.markedTextRange == nil && text.count > 15 {
                        textField.text = text.prefix(15).description
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
        if VIEW?.itemTextField.text == "@D0縻ﾝ" {
            adminViewPopUp()
            return
        }
        ///画面共通処理
        guard let VIEW = VIEW else {
            return
        }
        ///データ代入
        let data = VIEW.itemTextField.text
        let updateData:ProfileInfoLocalObject = realmMapping.updateObjectMapping(unManagedObject: ProfileInfoLocalObject(), managedObject: SELFPROFILE)
        updateData.lcl_UID = SELFPROFILE.Required_UID
        ///ローカルデータ登録
        switch objects {
        case .nickName:
            updateData.lcl_NickName = data
        case .aboutMe:
            updateData.lcl_AboutMeMassage = data
        case .area:
            updateData.lcl_Area = data
        }
        //登録後に画面に更新した値を適用するクロージャー
        let updateValueApply = {(kind:updateKind) in
            switch kind {
            case .nickName:
                self.VIEW?.itemTextField.text = updateData.lcl_NickName
                self.SELFPROFILE.Required_NickName = updateData.lcl_NickName!
            case .aboutMe:
                self.VIEW?.itemTextField.text = updateData.lcl_AboutMeMassage
                self.SELFPROFILE.Required_AboutMeMassage = updateData.lcl_AboutMeMassage!
            case .area:
                self.VIEW?.itemTextField.text = updateData.lcl_Area
                self.SELFPROFILE.Required_Area = updateData.lcl_Area!
            }
        }

        var LOCAL = TargetProfileLocalDataSetterManager(updateProfile: updateData)
        ///サーバデータ登録
        if let returnErr = PROFILESETTER.profileUpload(KIND: objects, Data: updateData) {
            createSheet(for: .Completion(title: "更新に失敗しました。再度行ってください。", {
                ///ローカル保存取りやめ
                LOCAL.commiting = false
            }), SelfViewController: self)
        } else {
            ///成功した場合ローカル保存実施
            LOCAL.commiting = true
            ///更新した値を画面にも適用
            ///画面が保持しているプロフィールデータも更新
            updateValueApply(objects)
        }
        self.delegate?.ButtonTappedActionChildDelegateAction()
    }
    
    func closeModalButttonClickedButtonTappedAction(button: UIButton, view: ModalBaseView) {
        ///クローズ処理
        self.delegate?.ButtonTappedActionChildDelegateAction()
    }
    
    ///ピッカーの決定ボタンを押下した際のアクション
    func pickerFinishedButtonTappedAction() {
        ///テキストチェック
        textCounterDecisionButtonEnable()
    }
}

extension SemiModalViewController{
    /// 不正エラー検出時処理
    func invalidUserCompletion() {
        createSheet(for: .Completion(title: "不正なユーザーの可能性があるため強制終了します。再登録してください。", {
            preconditionFailure()
        }), SelfViewController: self)
    }
}
//管理者権限付与画面に入った際の処理
extension SemiModalViewController {
    func adminViewPopUp() {
        // UIAlertControllerを作成
        let alertController = UIAlertController(title: "管理者画面", message: "", preferredStyle: .alert)

        // テキストフィールドを追加
        alertController.addTextField { (textField) in
            textField.placeholder = "PassWord"
        }

        // OKアクションを追加
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if let textFields = alertController.textFields, let text = textFields.first?.text {
                
                let ADMINHOSTGETTER = adminHostGetterManager()
                let ADMINHOSTSETTER = adminHostSetterManager()
                ADMINHOSTGETTER.passwordGetter { str in
                    alertController.dismiss(animated: true)
                    if str == text {
                        self.resultPopUp(message: "管理者権限が付与されました。")
                        ///管理者メンバーに追加
                        ADMINHOSTSETTER.memberUIDSetter(UID: self.SELFPROFILE.Required_UID, password: text)
                    } else {
                        self.resultPopUp(message: "画面を閉じてください。付与できません")
                    }
                }
            }
        }
        alertController.addAction(okAction)

        // キャンセルアクションを追加
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            // キャンセルボタンがタップされたときの処理
        }
        alertController.addAction(cancelAction)

        // UIAlertControllerを表示
        present(alertController, animated: true, completion: nil)
    }
    
    func resultPopUp (message:String) {
        // UIAlertControllerを作成
        let resultAlertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
        
        // OKアクションを追加
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        resultAlertController.addAction(okAction)
        
        // UIAlertControllerを表示
        present(resultAlertController, animated: true, completion: nil)
    }
    
}

