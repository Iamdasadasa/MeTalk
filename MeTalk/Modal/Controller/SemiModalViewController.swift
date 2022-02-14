//
//  SemiModalViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/12.
//

import Foundation
import UIKit


class SemiModalViewController:UIViewController,UITextFieldDelegate,TextFieldModalViewDelegateProtcol{

    

    ///インスタンス化
    let textFieldModalView = TextFieldModalView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = textFieldModalView
        ///デリゲート委譲
        textFieldModalView.delegate = self
        textFieldModalView.itemTextField.delegate = self
        
    }
}

//※文字制限を行うオブザーバー処理及び、ボタン活性化処理※
extension SemiModalViewController{
    ///    ///オブザーバー処理
    /// - Parameters:
    ///   - notification: オブザーバーから渡されたオブジェクト（ここではテキストフィールドに関するもの）
    /// - Returns: none
    @objc func textFieldDidChange(notification: NSNotification) {
      ///ボタン活性化チェック処理
      textFieldBrankCheck_ButtonActive()
      ///文字制限処理(10文字)
      let textField = notification.object as! UITextField
      if let text = textField.text {
        if textField.markedTextRange == nil && text.count > 10 {
            textField.text = text.prefix(10).description
        }
      }
    }
}

extension SemiModalViewController{
    ///    /// ボタン活性化及びテキスト入力チェック
    /// - Parameters:
    /// - Returns: none
    func textFieldBrankCheck_ButtonActive(){
        if textFieldModalView.itemTextField.text != ""{
            textFieldModalView.decisionButton.isEnabled = true
            textFieldModalView.decisionButton.backgroundColor = .orange
        } else {
            textFieldModalView.decisionButton.isEnabled = false
            textFieldModalView.decisionButton.backgroundColor = .gray
        }
    }
}

//※キーボードオプション※
extension SemiModalViewController{
    ///    ///リターンボタンを押下したらキーボードがしまわれる処理
    /// - Parameters:
    /// - Returns: none
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldModalView.itemTextField.resignFirstResponder()
        return true
    }
    ///    /// 空白の部分をタッチしたらキーボードがしまわれる処理
    /// - Parameters:
    /// - Returns: none
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textFieldModalView.endEditing(true)
    }

}

///決定ボタンを押下した時のデリゲート関数
extension SemiModalViewController{
    func dicisionButtonTappedAction(button: UIButton, view: TextFieldModalView) {
        print("押下されました")
        self.dismiss(animated: true, completion: nil)
    }
}
