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
    ///表示画面
    let nickNameSelectView = initialSettingNickNameSelectView()
    ///遷移先画面
    let finalConfirmViewController = initialSettingFinalConfirmViewController()
    ///戻るボタン
    var backButtonItem:UIBarButtonItem! // Backボタン
    
    override func viewDidLoad() {
        nickNameSelectView.delegate = self
        self.view = nickNameSelectView
        ///barボタン初期設定
        backButtonItem = UIBarButtonItem(title: "＜年齢選択", style: .plain, target: self, action: #selector(backButtonPressed(_:)))
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
        ///ニックネームデータ格納
        self.PROFILEINFODATA.nickName = PROFILEINFODATA.nickName
        ///ニックネームおよび年齢データおよび性別データ格納
        finalConfirmViewController.PROFILEINFODATA = self.PROFILEINFODATA
        ///画面遷移
        nextPushViewController(nextViewController: finalConfirmViewController)
    }
    
    /// 画面遷移
    /// - Parameter nextViewController: 最終確認画面
    func nextPushViewController(nextViewController: UIViewController) {
        let UINavigationController = UINavigationController(rootViewController: nextViewController)
        UINavigationController.modalPresentationStyle = .fullScreen
        self.present(UINavigationController, animated: false, completion: nil)
        self.slideInFromRight() // 遷移先の画面を横スライドで表示
    }

}
