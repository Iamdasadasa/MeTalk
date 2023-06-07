//
//  initialSettingGenderSelectViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/04/18.
//

import Foundation
import UIKit

class initialSettingGenderSelectionViewController:UIViewController{
    ///入力データ受け渡し用変数
    var PROFILEINFODATA = initialProfileInfo()
    ///遷移先画面
    let nextVC = initialSettingAgeSelectViewController()
    ///表示画面
    let GenderSelectionView = initialSettingGenderSelectionView()
    
    override func viewDidLoad() {
        self.GenderSelectionView.delegate = self
        self.view = GenderSelectionView
    }
}

extension initialSettingGenderSelectionViewController:initialSettingGenderSelectionViewDelegate {
    
    /// 画面上の決定ボタン押下時アクション
    /// - Parameter gender: 入力された性別情報
    func decisionButtonTappedAction(gender: GENDER) {
        ///性別情報を格納
        PROFILEINFODATA.gender = gender
        nextVC.PROFILEINFODATA = PROFILEINFODATA
        nextPushViewController(nextViewController: nextVC)
    }
    
    /// 次画面遷移
    /// - Parameter nextViewController: 年齢選択画面
    func nextPushViewController(nextViewController: UIViewController) {
        let UINavigationController = UINavigationController(rootViewController: nextViewController)
        UINavigationController.modalPresentationStyle = .fullScreen
        self.present(UINavigationController, animated: false, completion: nil)
        self.slideInFromRight() // 遷移先の画面を横スライドで表示
    }
}
