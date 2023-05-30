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
    let AgeSelectView = initialSettingAgeSelectView()
    let nickNameSelectViewController = initialSettingNicknameSelectViewController()
    
    var backButtonItem:UIBarButtonItem! // Backボタン
    
    override func viewDidLoad() {
        self.AgeSelectView.delegate = self
        self.view = AgeSelectView
        ///barボタン初期設定
        backButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(backButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = backButtonItem
        self.view.backgroundColor = .gray
    }
    
    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: false, completion: nil)
        self.slideOutToLeft()
     }
}

extension initialSettingAgeSelectViewController:initialSettingAgeSelectViewDelegate{
    func decisionButtonTappedAction(ageSelectionView: initialSettingAgeSelectView) {
        guard let SELECTTEDAGE = ageSelectionView.allAgeSelected() else {
            return
        }
        ///年齢データ格納
        self.PROFILEINFODATA.Age = SELECTTEDAGE
        ///年齢データおよび性別データ格納
        nickNameSelectViewController.PROFILEINFODATA = self.PROFILEINFODATA
        ///画面遷移
        nextPushViewController(nextViewController: nickNameSelectViewController)
                
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
    
}

