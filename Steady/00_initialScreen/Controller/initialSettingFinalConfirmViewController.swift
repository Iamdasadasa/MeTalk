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
    let USERHOSTING = RegisterHostSetter()
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
                createSheet(for: .Retry(title: "登録中にエラーが発生しました"), SelfViewController: self)
                //ローディング画面非表示
                self.LOADINGVIEW.loadingViewIndicator(isVisible: false)
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
        createSheet(for: .Alert(title: "登録処理で問題が発生しました", message: "もう一度試してください", buttonMessage: "OK", { result in
            if result {
                self.dismiss(animated: false, completion: nil)
                self.slideOutToLeft()
                return
            } else {
                self.dismiss(animated: false, completion: nil)
                self.slideOutToLeft()
                return
            }
        }), SelfViewController: self)
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
            LOCALPROFILEDATA.lcl_UID = USERUID
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
        
        createSheet(for: .Alert(title: "プライバシーポリシー及び利用規約の内容に同意します。", message: "内容は設定画面よりご確認いただけます。", buttonMessage: "OK", { result in
            if !result {
                createSheet(for: .Completion(title: "アプリを終了します", {
                    preconditionFailure()
                }), SelfViewController: self)
                return
            }
            ///ローディング画面表示
            self.LOADINGVIEW.loadingViewIndicator(isVisible: true)
            ///決定ボタンを重複押下できなくさせる
            initialSettingFinalConfirmView.decisionButton.isEnabled = false
            self.SignUp()
        }), SelfViewController: self)
    }
    
    private func SignUp() {
        ///権限登録処理
        USERHOSTING.signUpAuthRegister(callback: { Result in
            if case.Success(let UID) = Result {
                self.USERUID = UID
            }
            
            if case .failure(_) = Result {
                    ///エラー対応
                createSheet(for: .Retry(title: "ユーザー権限登録処理に失敗しました"), SelfViewController: self)
                return
            }
        })
    }
    
    private func authRegister(MYUID:String) {
        ///安全なデータにMapping準備
        let mapping = profileSafeDataMapping()
        ///ユーザー情報登録
        USERHOSTING.userInfoRegister(callback: { Result in
            ///情報登録成功
            if case.Success(let successMessage) = Result {
                ///ローディングビュー非表示
                self.LOADINGVIEW.loadingViewIndicator(isVisible: false)
                ///自身のデータをローカルに登録
                var LOCALSETTER = TargetProfileLocalDataSetterManager(updateProfile: self.LOCALPROFILEDATA)
                LOCALSETTER.commiting = true
                ///データを安全な型に変える
                mapping.USERLISTPROFILEMAPPING(callback: { safeData in
                    ///遷移先ページのインスタンス
                    let mainTabBarController = MainTabBarController(SELFINFO: safeData, ImageLocalObject: listUsersImageLocalObject())
                    //.partialCurlにするとバグるのでflipHorizontalに変更
                    mainTabBarController.modalTransitionStyle = .flipHorizontal
                    mainTabBarController.modalPresentationStyle = .fullScreen
                    self.present(mainTabBarController, animated: true, completion: nil)
                }, PROFILEINFO: self.LOCALPROFILEDATA, VC: self)
            }
            ///情報登録失敗
            if case .failure(let error) = Result {
                print(error.localizedDescription)
                ///エラー対応
                createSheet(for: .Retry(title: "ユーザー権限登録処理に失敗しました"), SelfViewController: self)
                ///ローディング画面非表示
                self.LOADINGVIEW.loadingViewIndicator(isVisible: false)
                self.finalConfirmView.decisionButton.isEnabled = true
            }
        }, USER: LOCALPROFILEDATA, uid: MYUID, signUpFlg: .general)
    }
    
}
