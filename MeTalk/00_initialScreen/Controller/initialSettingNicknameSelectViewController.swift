//
//  initialSettingNicknameSelectViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/05/30.
//

import Foundation
import UIKit

class initialSettingNicknameSelectViewController:UIViewController{
    ///プロファイル受け渡し用変数
    var PROFILEINFODATA = initialProfileInfo()
    let nickNameSelectView = initialSettingNickNameSelectView()
    
    var backButtonItem:UIBarButtonItem! // Backボタン
    
    override func viewDidLoad() {
        self.view = nickNameSelectView
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

extension initialSettingNicknameSelectViewController:initialSettingNickNameSelectViewDelegate{
    func decisionButtonTappedAction(ageSelectionView: initialSettingNickNameSelectView) {
        PROFILEINFODATA.nickName = ageSelectionView.nickNameInputTextField.text
        print("ニックネームは:\(PROFILEINFODATA.nickName)性別は:\(PROFILEINFODATA.gender)年齢は:\(PROFILEINFODATA.Age)")
    }
    
//    /// 画面遷移
//    /// - Parameter nextViewController: ニックネーム選択画面
//    func nextPushViewController(nextViewController: UIViewController) {
//        let UINavigationController = UINavigationController(rootViewController: nextViewController)
//        UINavigationController.modalPresentationStyle = .fullScreen
//        self.present(UINavigationController, animated: false, completion: nil)
//        self.slideInFromRight() // 遷移先の画面を横スライドで表示
//    }
//
}
