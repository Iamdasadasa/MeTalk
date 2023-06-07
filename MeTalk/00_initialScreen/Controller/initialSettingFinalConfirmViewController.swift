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
    ///ユーザーの基本的な通信処理をまとめた構造体（DIが行えるようにProtcol型とする)
    let USERHOSTING:firebaseHostingProtocol = profileInitHosting()
    ///プロファイル受け渡し用変数
    var PROFILEINFODATA = initialProfileInfo() {
        ///キャンセルして値を修正したパターンを考慮してdidsetにてViewの処理を行う
        didSet {
            ///barボタン初期設定
            backButtonItem = UIBarButtonItem(title: "＜ニックネーム選択", style: .plain, target: self, action: #selector(backButtonPressed(_:)))
            self.navigationItem.leftBarButtonItem = backButtonItem
            self.view.backgroundColor = .gray
            ///連携されてきた入力データ有無確認
            guard let gender = PROFILEINFODATA.gender,let age = PROFILEINFODATA.Age,let nickName = PROFILEINFODATA.nickName else {
                ///存在しなかった場合
                infoErrorBackToView()
                return
            }
            finalConfirmView.PROFILEINFODATA = self.PROFILEINFODATA
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
        
    }
}

extension initialSettingFinalConfirmViewController:initialSettingFinalConfirmViewDelegate{
    /// 決定ボタンを押下した際の処理
    /// - Parameters:
    ///   - button: 呼び出し元Viewの押下されたボタン
    ///   - view: 呼び出し元View
    /// - Returns: none
    func decisionButtonTappedAction(initialSettingFinalConfirmView: initialSettingFinalConfirmView) {
        ///サーバー接続中のローディング画面
        let LOADINGVIEW = LOADING(loadingView: LoadingView())
        ///ローディング画面表示
        LOADINGVIEW.loadingViewIndicator(isVisible: true)
        ///決定ボタンを重複押下できなくさせる
        initialSettingFinalConfirmView.decisionButton.isEnabled = false
        ///ユーザーが入力してきた情報を抽出
        guard let gender = PROFILEINFODATA.gender,let age = PROFILEINFODATA.Age,let nickName = PROFILEINFODATA.nickName else {
            infoErrorBackToView()
            return
        }
        
        var USERUID:String? {
            ///下記の権限登録処理でUSERUIDに値が入ってから実行
            didSet {
                ///データ登録用Local構造体及び初期値
                var DefaultIntValue = {(I:USERINFODEFAULTVALUE) in
                    return I.NumObjec
                }
                var DefaultStrValue = {(S:USERINFODEFAULTVALUE) in
                    return S.StrObjec
                }
                ///genderを数値の変換
                let sex = {
                    switch gender {
                    case .none:
                        return 0
                    case .male:
                        return 1
                    case .female:
                        return 2
                    }
                }()
                
                let LOCALPROFILEDATA = profileInfoLocal()
                LOCALPROFILEDATA.lcl_NickName = nickName
                LOCALPROFILEDATA.lcl_Sex = sex
                LOCALPROFILEDATA.lcl_AboutMeMassage = DefaultStrValue(.AboutMeMassage)
                LOCALPROFILEDATA.lcl_Age = age.convertToFormattedDateInt(targetAgeString: age, Type: .EightDigit) ?? DefaultIntValue(.Age)
                LOCALPROFILEDATA.lcl_Area = DefaultStrValue(.area)
                LOCALPROFILEDATA.lcl_DateCreatedAt = Date()
                LOCALPROFILEDATA.lcl_DateUpdatedAt = Date()
                ///ユーザー情報登録
                USERHOSTING.FireStoreUserInfoRegister(callback: { FireBaseResult in
                    ///情報登録成功
                    if case.Success(let successMessage) = FireBaseResult {
                        ///ローディングビュー非表示
                        LOADINGVIEW.loadingViewIndicator(isVisible: false)
                        ///遷移先ページのインスタンス
                        let mainTabBarController = MainTabBarController()
                        //.partialCurlにするとバグるのでflipHorizontalに変更
                        mainTabBarController.modalTransitionStyle = .flipHorizontal
                        mainTabBarController.modalPresentationStyle = .fullScreen

                        let LOCAL = localProfileDataStruct(updateObject: LOCALPROFILEDATA, UID: Auth.auth().currentUser!.uid)
                        LOCAL.userProfileLocalDataExtraRegist()
                        
                        self.present(mainTabBarController, animated: true, completion: nil)
                    }
                    ///情報登録失敗
                    if case .failure(let error) = FireBaseResult {
                        ///エラー対応
                        print(error.localizedDescription)
                        let action = actionSheets(dicidedOrOkOnlyTitle: "ユーザー情報登録処理に失敗しました", message: "もう一度お試しください", buttonMessage: "OK")
                        action.okOnlyAction(callback: { result in
                            switch result {
                            case .one:
                                ///ローディング画面非表示
                                LOADINGVIEW.loadingViewIndicator(isVisible: false)
                            }
                        }, SelfViewController: self)
                    }
                }, USER: LOCALPROFILEDATA, uid: USERUID!)
            }
        }
        
        ///権限登録処理
        USERHOSTING.FireStoreSignUpAuthRegister(callback: { FireBaseResult in
            if case.Success(let UID) = FireBaseResult {
                USERUID = UID
            }
            
            if case .failure(let error) = FireBaseResult {
                ///エラー対応
                print(error.localizedDescription)
                let action = actionSheets(dicidedOrOkOnlyTitle: "ユーザー権限登録処理に失敗しました", message: "もう一度お試しください", buttonMessage: "OK")
                
                action.okOnlyAction(callback: { result in
                    switch result {
                    case .one:
                        ///ローディング画面非表示
                        LOADINGVIEW.loadingViewIndicator(isVisible: false)
                    }
                }, SelfViewController: self)
                return
            }
        })
    }
}
