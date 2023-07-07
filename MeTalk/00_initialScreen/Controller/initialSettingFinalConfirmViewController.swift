//
//  initialSettingFinalConfirmViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/05/31.
//

import Foundation
import UIKit
import Firebase
import RealmSwift

class initialSettingFinalConfirmViewController:UIViewController{
    var backButtonItem:UIBarButtonItem! // Backボタン
    ///表示画面
    let finalConfirmView = initialSettingFinalConfirmView()
    ///サーバー接続中のローディング画面
    let LOADINGVIEW = LOADING(loadingView: LoadingView(),BackClear: false)
    ///ユーザーの基本的な通信処理をまとめた構造体（DIが行えるようにProtcol型とする)
    let USERHOSTING:ProfileRegisterProtocol = MyProfileSetterManager()
    ///前画面より取得されるデータの格納変数
    var gender:GENDER = .none
    var nickName:String = ""
    var EightDigitAge:Int = 20
    ///ローカルデータ用構造体
    let LOCALPROFILEDATA = ProfileInfoLocalObject()
    ///プロファイル受け渡し用変数
    var PROFILEINFODATA = initialProfileInfo() {
        ///キャンセルして値を修正したパターンを考慮してdidsetにてViewの処理を行う
        willSet {
            ///barボタン初期設定
            backButtonItem = UIBarButtonItem(title: "＜ニックネーム選択", style: .plain, target: self, action: #selector(backButtonPressed(_:)))
            self.navigationItem.leftBarButtonItem = backButtonItem
            self.view.backgroundColor = .gray
            ///連携されてきた入力データ有無確認
            guard let gender = newValue.gender,let age = newValue.Age,let nickName = newValue.nickName else {
                ///存在しなかった場合
                infoErrorBackToView()
                return
            }
            ///年齢変換
            guard let EightDigitAge = age.convertToFormattedDateInt(targetAgeString: age, Type: .EightDigit) else {
                ///エラー対応
                createSheet(callback: {
                    ///ローディング画面非表示
                    self.LOADINGVIEW.loadingViewIndicator(isVisible: false)
                }, for: .Retry(title: "登録中にエラーが発生しました"), SelfViewController: self)
                return
            }
            ///情報格納
            self.gender = gender
            self.EightDigitAge = EightDigitAge
            self.nickName = nickName
            ///画面表示するプロフィール情報更新
            finalConfirmView.profileValueSetUp(gender: gender, age: age, nickname: nickName)
            self.view = finalConfirmView
        }
    }
    
    override func viewDidLoad() {
        ///デリゲート適用
        finalConfirmView.delegate = self
    }
    
    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: false, completion: nil)
        self.slideOutToLeft()
     }
    
    ///前の画面に戻させる処理
    func infoErrorBackToView() {
        createSheet(callback: {
            self.dismiss(animated: false, completion: nil)
            self.slideOutToLeft()
            return
        }, for: .Alert(title: "登録処理で問題が発生しました", message: "もう一度試してください1", buttonMessage: "OK"), SelfViewController: self)
    }
    
    
    var USERUID:String? {
        
        ///下記の権限登録処理でUSERUIDに値が入ってから実行
        didSet {
            ///サーバーでは性別を数字で管理するため数値を代入
            let genderNumber = gender.rawValue

            ///ローカルデータ構造体格納
            LOCALPROFILEDATA.lcl_NickName = nickName
            LOCALPROFILEDATA.lcl_Sex = genderNumber
            LOCALPROFILEDATA.lcl_AboutMeMassage = USERINFODEFAULTVALUE.aboutMeMassage.value
            LOCALPROFILEDATA.lcl_Age = EightDigitAge
            LOCALPROFILEDATA.lcl_Area = USERINFODEFAULTVALUE.area.value
            LOCALPROFILEDATA.lcl_DateCreatedAt = Date()
            LOCALPROFILEDATA.lcl_DateUpdatedAt = Date()
            
            ///ユーザー情報登録
            authRegister(MYUID: USERUID!)
        }
    }
}

extension initialSettingFinalConfirmViewController:initialSettingFinalConfirmViewDelegate{
    /// 決定ボタンを押下した際の処理
    /// - Parameters:
    ///   - button: 呼び出し元Viewの押下されたボタン
    ///   - view: 呼び出し元View
    /// - Returns: none
    func decisionButtonTappedAction(initialSettingFinalConfirmView: initialSettingFinalConfirmView) {
        ///ローディング画面表示
        LOADINGVIEW.loadingViewIndicator(isVisible: true)
        ///決定ボタンを重複押下できなくさせる
        initialSettingFinalConfirmView.decisionButton.isEnabled = false
        SignUp()
    }
    
    private func SignUp() {
        ///権限登録処理
        USERHOSTING.SignUpAuthRegister(callback: { Result in
            if case.Success(let UID) = Result {
                self.USERUID = UID
            }
            
            if case .failure(_) = Result {
                    ///エラー対応
                createSheet(callback: {
                        ///ローディング画面非表示
                    self.LOADINGVIEW.loadingViewIndicator(isVisible: false)
                    }, for: .Retry(title: "ユーザー権限登録処理に失敗しました"), SelfViewController: self)
                return
            }
        })
    }
    
    private func authRegister(MYUID:String) {
        ///ユーザー情報登録
        USERHOSTING.UserInfoRegister(callback: { Result in
            ///情報登録成功
            if case.Success(let successMessage) = Result {
                ///ローディングビュー非表示
                self.LOADINGVIEW.loadingViewIndicator(isVisible: false)
                ///遷移先ページのインスタンス
                let mainTabBarController = MainTabBarController()
                //.partialCurlにするとバグるのでflipHorizontalに変更
                mainTabBarController.modalTransitionStyle = .flipHorizontal
                mainTabBarController.modalPresentationStyle = .fullScreen
                ///自身のデータをローカルに登録
                var LOCALSETTER = TargetProfileLocalDataSetterManager(updateProfile: self.LOCALPROFILEDATA)
                LOCALSETTER.commiting = true
                
                self.present(mainTabBarController, animated: true, completion: nil)
            }
            ///情報登録失敗
            if case .failure(let error) = Result {
                ///エラー対応
                createSheet(callback: {
                    ///ローディング画面非表示
                    self.LOADINGVIEW.loadingViewIndicator(isVisible: false)
                }, for: .Retry(title: "ユーザー情報登録処理に失敗しました"), SelfViewController: self)
            }
        }, USER: LOCALPROFILEDATA, uid: MYUID)
    }
    
}
