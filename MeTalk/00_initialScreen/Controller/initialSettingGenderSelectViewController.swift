//
//  initialSettingGenderSelectViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/04/18.
//

import Foundation
import UIKit

class initialSettingGenderSelectionViewController:UIViewController{
    var PROFILEINFODATA = initialProfileInfo()
    let nextVC = initialSettingAgeSelectViewController()
    let GenderSelectionView = initialSettingGenderSelectionView()
    
    override func viewDidLoad() {
        self.GenderSelectionView.delegate = self
        self.view = GenderSelectionView
    }
}

extension initialSettingGenderSelectionViewController:initialSettingGenderSelectionViewDelegate {
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
