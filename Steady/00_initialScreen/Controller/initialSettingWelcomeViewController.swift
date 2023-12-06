//
//  initialSettingWelcomeViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/04/14.
//

import Foundation
import UIKit

class initialSettingWelcomeViewController:UIViewController,welcomeViewObjectDelegateProtocol {

    let welcomeView = initialSettingWelcomeView()
    
    override func viewDidLoad() {
        welcomeView.delegateanimationLabel = self
        self.view = welcomeView
    }
    /// ビューのアニメーションを実行
    /// - Parameters:
    ///   - fadeInLabel: フェードインするUILabel
    ///   - typingLabel: タイピングアニメーション対象UILabel
    func animationLabel(fadeInLabel: UILabel, typingLabel: CLTypingLabel) {
        UIView.animate(withDuration: 3.0, animations: {
            fadeInLabel.alpha = 1.0
        }) {_ in
            fadeInLabel.alpha = 0.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                ///テキスト挿入時にアニメーション開始
                typingLabel.text = "Welcome To Penguin"
                typingLabel.onTypingAnimationFinished = {
                    self.goToNextScreen()
                }
            }
        }
    }
    /**
     次の画面へ遷移
     スライドアウトアニメーションを実行してビューを上部に遷移する
     */
    func goToNextScreen() {
        let nextVC = initialSettingGenderSelectionViewController()
        self.slideOutToTop()
        nextVC.modalPresentationStyle = .fullScreen
//        self.navigationController?.pushViewController(navigationController, animated: true)
        self.present(nextVC, animated: false)
    }
}

