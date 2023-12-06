//
//  SemiModalViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/11/07.
//

import Foundation
import UIKit
import Firebase

protocol AdminDammyProfileCreateModalViewControllerDelegateProtcol:AnyObject{
    func ButtonTappedActionChildDelegateAction(inputData:String,Item: DammyCreateModalItems)
}

class AdminDammyProfileCreateModalViewController:UIViewController,UITextFieldDelegate{
    ///インスタンス化(View)
    var VIEW:AdminDammyProfileCreateModalView?
    let modalImageData = ModalImageData()
    ///Viewフラグ判断変数
    var dicidedModal:DammyCreateModalItems
    ///デリゲート変数
    weak var delegate:AdminDammyProfileCreateModalViewControllerDelegateProtcol?

    init(dicidedModal:DammyCreateModalItems){
        self.dicidedModal = dicidedModal
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///画面共通処理
        self.VIEW = AdminDammyProfileCreateModalView(ModalItems: self.dicidedModal, frame: self.view.frame)
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

            ///オブザーバー（テキストフィールドの文字が変更されたタイミング）
            NotificationCenter.default.addObserver(self,
              selector: #selector(textFieldDidChange(notification:)),
              name: UITextField.textDidChangeNotification,
              object: VIEW.itemTextField)
        ///ひとこと編集
        case .aboutMe:
            self.view = VIEW
            ///オブザーバー（テキストフィールドの文字が変更されたタイミング）
            NotificationCenter.default.addObserver(self,
              selector: #selector(textFieldDidChange(notification:)),
              name: UITextField.textDidChangeNotification,
              object: VIEW.itemTextField)
        ///住まい編集
        case .Area:
            self.view = VIEW
        case .birth:
            self.view = VIEW
        case .gender:
            self.view = VIEW
        }
    }
    ///テキストが0文字だった場合は決定ボタン無効化
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
extension AdminDammyProfileCreateModalViewController{
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
extension AdminDammyProfileCreateModalViewController{
    
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
extension AdminDammyProfileCreateModalViewController:AdminDammyProfileCreateModalViewDelegateProtcol{
    ///決定ボタン押下　view: NickNameTextFieldModalView
    func dicisionButtonTappedAction(button: UIButton, Item: DammyCreateModalItems) {
        ///画面共通処理
        guard let VIEW = VIEW else {
            return
        }
        ///データ代入
        let data = VIEW.itemTextField.text
        
        guard let data = data else {
            createSheet(for: .Completion(title: "入力がありません", {}), SelfViewController: self)
            return
        }

        self.delegate?.ButtonTappedActionChildDelegateAction(inputData: data, Item: dicidedModal)
    }
    
    func closeModalButttonClickedButtonTappedAction(button: UIButton, view: AdminDammyProfileCreateModalView) {
        ///クローズ処理
        self.delegate?.ButtonTappedActionChildDelegateAction(inputData: "",Item: dicidedModal)
    }
    
    ///ピッカーの決定ボタンを押下した際のアクション
    func pickerFinishedButtonTappedAction() {
        ///テキストチェック
        textCounterDecisionButtonEnable()
    }
}


