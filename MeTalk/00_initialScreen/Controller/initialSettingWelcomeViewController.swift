//
//  initialSettingWelcomeViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/04/14.
//

import Foundation
import UIKit

class intialSettingWelcomeViewController:UIViewController,welcomeViewDelegateProtocol,welcomeViewObjectDelegateProtocol {
    override func viewDidLoad() {
        // 初期設定のウェルカム画面を表示し、デリゲートを自分自身に設定
        let initialSettingWelcomeView = initialSettingWelcomeView()
        initialSettingWelcomeView.delegateFadeIn = self
        initialSettingWelcomeView.delegateUIViewAnimate = self
        self.view = initialSettingWelcomeView
    }
    
    /**
     "ようこそ"のラベルをフェードインするアニメーションを実行します。
     
     - Parameters:
         - duration: アニメーションの時間（秒）。デフォルト値は0.5秒です。
     */
    func fadeInLabel(fadeInLabel: UILabel) {
        UIView.animate(withDuration: 2.0) {
            fadeInLabel.alpha = 1.0
        }
    }
    
    func UIViewAnimateStart(UIview: UIView) {
        UIView.animate(withDuration: 0.0) {
            let transition = CATransition()
            transition.duration = 1.0
            transition.type = .reveal
            transition.subtype = .fromBottom
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            UIview.layer.add(transition, forKey: nil)
        }
    }
}

