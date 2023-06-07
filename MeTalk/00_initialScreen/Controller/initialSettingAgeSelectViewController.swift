//
//  initialSettingAgeSelectViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/05/23.
//

import Foundation
import UIKit

class initialSettingAgeSelectViewController:UIViewController{
    ///プロファイル受け渡し用変数
    var PROFILEINFODATA = initialProfileInfo()
    ///表示画面
    let AgeSelectView = initialSettingAgeSelectView()
    ///遷移先画面
    let nextVC = initialSettingNicknameSelectViewController()
    ///戻るボタン
    var backButtonItem:UIBarButtonItem! // Backボタン
    
    override func viewDidLoad() {
        self.AgeSelectView.delegate = self
        self.view = AgeSelectView
        ///barボタン初期設定
        backButtonItem = UIBarButtonItem(title: "＜性別選択", style: .plain, target: self, action: #selector(backButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = backButtonItem
        self.view.backgroundColor = .gray
    }
    
    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: false, completion: nil)
        self.slideOutToLeft()
     }
}

extension initialSettingAgeSelectViewController:initialSettingAgeSelectViewDelegate{
    
    /// 画面の決定ボタンを押下した際の処理
    /// - Parameter ageSelectionView: 表示画面丸ごと
    func decisionButtonTappedAction(ageSelectionView: initialSettingAgeSelectView) {
        guard let AGE = formattedBirth() else {
            return
        }
        ///年齢データ格納
        self.PROFILEINFODATA.Age = AGE
        print(self.PROFILEINFODATA.Age)
        ///年齢データおよび性別データ格納
        nextVC.PROFILEINFODATA = self.PROFILEINFODATA
        ///画面遷移
        nextPushViewController(nextViewController: nextVC)
                
        return
    }
    
    /// 画面遷移
    /// - Parameter nextViewController: ニックネーム選択画面
    func nextPushViewController(nextViewController: UIViewController) {
        let UINavigationController = UINavigationController(rootViewController: nextViewController)
        UINavigationController.modalPresentationStyle = .fullScreen
        self.present(UINavigationController, animated: false, completion: nil)
        self.slideInFromRight() // 遷移先の画面を横スライドで表示
    }
    
    ///Viewから取得した生年月日をスラッシュ形式の文字列に変更
    func formattedBirth() -> String? {
        let allCustomTextField = AgeSelectView.allCustomTextField
        var BirthString = ""
        
        for customTextField in allCustomTextField {
            guard let selectedAge = customTextField.selectedAge else {
                return nil
            }
            if customTextField.birthType == .day {
                BirthString += String(selectedAge)
            } else {
                BirthString += String("\(selectedAge)/")
            }
        }
        return BirthString.convertToFormattedDateString(targetAgeString: BirthString, Type: .EightDigit)
    }
    
}

