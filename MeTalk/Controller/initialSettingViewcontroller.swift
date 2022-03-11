//
//  initialSettingViewcontroller.swift
//  Me2
//
//  Created by KOJIRO MARUYAMA on 2022/01/29.
//

import Foundation
import UIKit
import Firebase

class initialSettingViewcontroller:UIViewController{
    ///インスタンス化（View）
    let initialSettingView = InitialSettingView()
    let loadingView = LoadingView()
    ///インスタンス化（Model）
    let initialSettingData = InitialSettingData()
    let userDataManagedData = UserDataManagedData()
    ///ボタン押下中フラグ
    var buttonPushingFlg:Int? = nil
    ///性別タグNo格納
    var SexNo:Int? = nil
    
    
    override func viewDidLoad() {
        self.view = initialSettingView
        ///デリゲート委譲
        initialSettingView.delegate = self
        initialSettingView.nicknameTextField.delegate = self
        ///画像初期設定
        imageSetUp()
        
        ///オブザーバー（テキストフィールドの文字が変更されたタイミング）
        NotificationCenter.default.addObserver(self,
          selector: #selector(textFieldDidChange(notification:)),
          name: UITextField.textDidChangeNotification,
          object: initialSettingView.nicknameTextField)
    }
    ///オブザーバー破棄
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
}

//※文字制限を行うオブザーバー処理及び、ボタン活性化処理※
extension initialSettingViewcontroller{

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

//※Viewのオブジェクトに画像挿入※
extension initialSettingViewcontroller{
    ///    ///ボタン画像セットアップ
    /// - Parameters:
    /// - Returns: none
    func imageSetUp(){
        ///ボタンの初期画像挿入
        initialSettingView.malebutton.setImage(initialSettingData.maleBlackImage, for: .normal)
        initialSettingView.femalebutton.setImage(initialSettingData.femaleBlackImage, for: .normal)
        initialSettingView.unknownSexbutton.setImage(initialSettingData.unknownSexBlackImage, for: .normal)
    }
}

//※キーボードオプション※
extension initialSettingViewcontroller:UITextFieldDelegate{
    ///    ///リターンボタンを押下したらキーボードがしまわれる処理
    /// - Parameters:
    /// - Returns: none
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        initialSettingView.nicknameTextField.resignFirstResponder()
        return true
    }
    ///    /// 空白の部分をタッチしたらキーボードがしまわれる処理
    /// - Parameters:
    /// - Returns: none
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        initialSettingView.endEditing(true)
    }

}

extension initialSettingViewcontroller{
    ///    /// ボタン活性化及びテキスト入力チェック
    /// - Parameters:
    /// - Returns: none
    func textFieldBrankCheck_ButtonActive(){
        if let flg = self.buttonPushingFlg,initialSettingView.nicknameTextField.text != ""{
            initialSettingView.dicisionButton.isEnabled = true
            initialSettingView.dicisionButton.backgroundColor = .orange
        } else {
            initialSettingView.dicisionButton.isEnabled = false
            initialSettingView.dicisionButton.backgroundColor = .gray
        }
    }
}

extension initialSettingViewcontroller:InitialSettingViewDelegateProtcol{
    ///    /// ボタンのタグで変更する画像を判断
    /// - Parameters:
    ///   - button: 呼び出し元Viewの押下されたボタン
    ///   - view: 呼び出し元View
    /// - Returns: none
    func SexButtonTappedAction(button: UIButton,view: InitialSettingView) {
        let Button = button
        buttonPushingFlg = 1
        switch Button.tag {
        case 0:
            Button.setImage(initialSettingData.unknownSexOrangeImage, for: .normal)
            ChangeToUnchecked(num: 0,argView:view)
        case 1:
            Button.setImage(initialSettingData.maleOrangeImage, for: .normal)
            ChangeToUnchecked(num: 1,argView:view)
        case 2:
            Button.setImage(initialSettingData.femaleOrangeImage, for: .normal)
            ChangeToUnchecked(num: 2,argView:view)
        default: break
        }
        SexNo = Button.tag
        textFieldBrankCheck_ButtonActive()
    }
    
    ///    /// 変更された画像以外の画像を初期値の画像に戻す処理
    /// - Parameters:
    ///   - num: 呼び出し元Viewの押下されたボタンのtagのナンバー
    ///   - argView: 呼び出し元View
    /// - Returns: none
    func ChangeToUnchecked(num:Int,argView:InitialSettingView){
        for v in argView.subviews {
            if let v = v as? UIButton, num == 0{
                switch v.tag {
                case 1:
                    v.setImage(initialSettingData.maleBlackImage, for: .normal)
                case 2:
                    v.setImage(initialSettingData.femaleBlackImage, for: .normal)
                default: break
                }
            } else if let v = v as? UIButton, num == 1{
                switch v.tag {
                case 0:
                    v.setImage(initialSettingData.unknownSexBlackImage, for: .normal)
                case 2:
                    v.setImage(initialSettingData.femaleBlackImage, for: .normal)
                default: break
                }
            } else if let v = v as? UIButton, num == 2{
                switch v.tag {
                case 0:
                    v.setImage(initialSettingData.unknownSexBlackImage, for: .normal)
                case 1:
                    v.setImage(initialSettingData.maleBlackImage, for: .normal)
                default: break
                }
            }
        }
    }
    ///    /// 決定ボタンを押下した際の処理
    /// - Parameters:
    ///   - button: 呼び出し元Viewの押下されたボタン
    ///   - view: 呼び出し元View
    /// - Returns: none
    func dicisionButtonTappedAction(button: UIButton, view: InitialSettingView) {
        ///一回ボタンを押したら二回目は押せなくする。
        button.isEnabled = false
        ///匿名登録処理
        userDataManagedData.signInAnonymously(callback: {errorFlg in
            if errorFlg == nil {
                ///自身のloadingView をメイン Window の Subview に追加して画面に表示
                UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.addSubview(self.loadingView)
                ///遷移先ページのインスタンス
                let mainTabBarController = MainTabBarController()
                //.partialCurlにするとバグるのでflipHorizontalに変更
                mainTabBarController.modalTransitionStyle = .flipHorizontal
                mainTabBarController.modalPresentationStyle = .fullScreen
                ///3秒後に execute のコードが実行されるようにする。
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                    self.present(mainTabBarController, animated: true, completion: nil)
                })
            } else {
                ///コールバック関数でエラーが返ってきた場合は全てこちらで処理。
                let dialog = UIAlertController(title: "ユーザー情報の登録に失敗", message: "もう一度やり直してください\(errorFlg)", preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog, animated: true, completion: nil)
            }},nickName: self.initialSettingView.nicknameTextField.text, SexNo: self.SexNo)
    }
}
