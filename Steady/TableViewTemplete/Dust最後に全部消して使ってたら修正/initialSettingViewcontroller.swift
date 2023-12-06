////
////  initialSettingViewcontroller.swift
////  Me2
////
////  Created by KOJIRO MARUYAMA on 2022/01/29.
////
//
//import Foundation
//import UIKit
//import Firebase
//import RealmSwift
//
//
//class initialSettingViewcontroller:UIViewController{
//    ///インスタンス化（View）
//    var initialSettingView:InitialSettingView!
//    ///ロード中に表示する画面
//    let loadingView = LoadingView()
//    ///インスタンス化（Model）
//    let initialSettingData = InitialSettingData()
//
//    ///ボタン押下中フラグ
//    var buttonPushingFlg:Int? = nil
//    ///性別タグNo格納
//    var SexNo:Int? = nil
//    ///ユーザーの基本的な通信処理をまとめた構造体（DIが行えるようにProtcol型とする)
//    let USERHOSTING:firebaseHostingProtocol = profileInitHosting()
//
//    
//    override func viewDidLoad() {
//        ///Viewのインスタンス化
//        initialSettingView = InitialSettingView()
//        ///各ボタンを格納
//        initialSettingView.buttons = [initialSettingView.femalebutton,initialSettingView.malebutton,initialSettingView.unknownSexbutton]
//        ///Viewを設定
//        self.view = initialSettingView
//        ///デリゲート委譲
//        initialSettingView.delegate = self
//        initialSettingView.nicknameTextField.delegate = self
//        
//        ///オブザーバー（テキストフィールドの文字が変更されたタイミング）
//        NotificationCenter.default.addObserver(self,
//          selector: #selector(textFieldDidChange(notification:)),
//          name: UITextField.textDidChangeNotification,
//          object: initialSettingView.nicknameTextField)
//    }
//    ///オブザーバー破棄
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//}
//
////※文字制限を行うオブザーバー処理及び、ボタン活性化処理※
//extension initialSettingViewcontroller{
//    ///    ///オブザーバー処理
//    /// - Parameters:
//    ///   - notification: オブザーバーから渡されたオブジェクト（ここではテキストフィールドに関するもの）
//    /// - Returns: none
//    @objc func textFieldDidChange(notification: NSNotification) {
//      ///ボタン活性化チェック処理
//      textFieldBrankCheck_ButtonActive()
//      ///文字制限処理(10文字)
//      let textField = notification.object as! UITextField
//      if let text = textField.text {
//        if textField.markedTextRange == nil && text.count > 10 {
//            textField.text = text.prefix(10).description
//        }
//      }
//    }
//}
//
////※キーボードオプション※
//extension initialSettingViewcontroller:UITextFieldDelegate{
//    ///    ///リターンボタンを押下したらキーボードがしまわれる処理
//    /// - Parameters:
//    /// - Returns: none
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        initialSettingView.nicknameTextField.resignFirstResponder()
//        return true
//    }
//    ///    /// 空白の部分をタッチしたらキーボードがしまわれる処理
//    /// - Parameters:
//    /// - Returns: none
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        initialSettingView.endEditing(true)
//    }
//}
//
//extension initialSettingViewcontroller{
//    ///    /// ボタン活性化及びテキスト入力チェック
//    /// - Parameters:
//    /// - Returns: none
//    func textFieldBrankCheck_ButtonActive(){
//        if let flg = self.buttonPushingFlg,initialSettingView.nicknameTextField.text != ""{
//            initialSettingView.dicisionButton.isEnabled = true
//            initialSettingView.dicisionButton.backgroundColor = .orange
//        } else {
//            initialSettingView.dicisionButton.isEnabled = false
//            initialSettingView.dicisionButton.backgroundColor = .gray
//        }
//    }
//}
//
//extension initialSettingViewcontroller:InitialSettingViewDelegateProtcol{
//    ///    /// ボタンのタグで変更する画像を判断
//    /// - Parameters:
//    ///   - button: 呼び出し元Viewの押下されたボタン
//    ///   - view: 呼び出し元View
//    /// - Returns: none
//    func SexButtonTappedAction(button: SexButton,view: InitialSettingView) {
//        ///性別ボタンが押されているか判断する変数
//        buttonPushingFlg = 1
//        ///ボタンの画像変更
//        button.ChangeImage()
//        ///サーバー送信用性別判断変数
//        SexNo = button.tag
//        /// ボタン活性化チェック
//        textFieldBrankCheck_ButtonActive()
//    }
//    
//    ///    /// 決定ボタンを押下した際の処理
//    /// - Parameters:
//    ///   - button: 呼び出し元Viewの押下されたボタン
//    ///   - view: 呼び出し元View
//    /// - Returns: none
//    func dicisionButtonTappedAction(button: UIButton, view: InitialSettingView) {
//        ///サーバー接続中のローディング画面
//        let LOADINGVIEW = LOADING(loadingView: LoadingView())
//        ///ローディング画面表示
//        LOADINGVIEW.loadingViewIndicator(isVisible: true)
//
//        ///決定ボタンの重複タップは押せなくする。
//        button.isEnabled = false
//        ///Viewから取得したテキスト
//        guard let nickName = self.initialSettingView.nicknameTextField.text,let SexNo = self.SexNo else {
//            ///エラー対応
//            let action = actionSheets(dicidedOrOkOnlyTitle: "ニックネームもしくは性別が選択されていません", message: "もう一度お試しください", buttonMessage: "OK")
//            action.okOnlyAction(callback: { result in
//                switch result {
//                case .one:
//                    ///ローディング画面非表示
//                    LOADINGVIEW.loadingViewIndicator(isVisible: false)
//                }
//            }, SelfViewController: self)
//            return
//        }
//        ///ユーザーの基本的な通信処理をまとめた構造体（DIが行えるようにProtcol型とする
//        ///let USERHOSTING = profileInitHosting()
//
//        ///ユーザー情報登録(権限登録処理が完了してから実行)
//        var USERUID:String? {
//            ///USERUIDに値が入ってから実行
//            didSet {
//                ///データ登録用Local構造体及び初期値
//                var DefaultIntValue = {(I:USERINFODEFAULTVALUE) in
//                    return I.NumObjec
//                }
//                var DefaultStrValue = {(S:USERINFODEFAULTVALUE) in
//                    return S.StrObjec
//                }
//                let LOCALPROFILEDATA = profileInfoLocal()
//                LOCALPROFILEDATA.lcl_NickName = nickName
//                LOCALPROFILEDATA.lcl_Sex = SexNo
//                LOCALPROFILEDATA.lcl_AboutMeMassage = DefaultStrValue(.AboutMeMassage)
//                LOCALPROFILEDATA.lcl_Age = DefaultIntValue(.Age)
//                LOCALPROFILEDATA.lcl_Area = DefaultStrValue(.area)
//                LOCALPROFILEDATA.lcl_DateCreatedAt = Date()
//                LOCALPROFILEDATA.lcl_DateUpdatedAt = Date()
//                ///ユーザー情報登録
//                USERHOSTING.FireStoreUserInfoRegister(callback: { FireBaseResult in
//                    ///情報登録成功
//                    if case.Success(let successMessage) = FireBaseResult {
//                        ///ローディングビュー非表示
//                        LOADINGVIEW.loadingViewIndicator(isVisible: false)
//                        ///遷移先ページのインスタンス
//                        let mainTabBarController = MainTabBarController()
//                        //.partialCurlにするとバグるのでflipHorizontalに変更
//                        mainTabBarController.modalTransitionStyle = .flipHorizontal
//                        mainTabBarController.modalPresentationStyle = .fullScreen
//
//                        let LOCAL = localProfileDataStruct(updateObject: LOCALPROFILEDATA, UID: Auth.auth().currentUser!.uid)
//                        LOCAL.userProfileLocalDataExtraRegist()
//                        
//                        self.present(mainTabBarController, animated: true, completion: nil)
//                    }
//                    ///情報登録失敗
//                    if case .failure(let error) = FireBaseResult {
//                        ///エラー対応
//                        print(error.localizedDescription)
//                        let action = actionSheets(dicidedOrOkOnlyTitle: "ユーザー情報登録処理に失敗しました", message: "もう一度お試しください", buttonMessage: "OK")
//                        action.okOnlyAction(callback: { result in
//                            switch result {
//                            case .one:
//                                ///ローディング画面非表示
//                                LOADINGVIEW.loadingViewIndicator(isVisible: false)
//                            }
//                        }, SelfViewController: self)
//                    }
//                }, USER: LOCALPROFILEDATA, uid: USERUID!)
//            }
//        }
//        
//        ///権限登録処理
//        USERHOSTING.FireStoreSignUpAuthRegister(callback: { FireBaseResult in
//            if case.Success(let UID) = FireBaseResult {
//                USERUID = UID
//            }
//            
//            if case .failure(let error) = FireBaseResult {
//                ///エラー対応
//                print(error.localizedDescription)
//                let action = actionSheets(dicidedOrOkOnlyTitle: "ユーザー権限登録処理に失敗しました", message: "もう一度お試しください", buttonMessage: "OK")
//                
//                action.okOnlyAction(callback: { result in
//                    switch result {
//                    case .one:
//                        ///ローディング画面非表示
//                        LOADINGVIEW.loadingViewIndicator(isVisible: false)
//                    }
//                }, SelfViewController: self)
//                return
//            }
//        })
//    }
//}
