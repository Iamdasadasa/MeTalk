//
//  initialSettingView_Gender.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/04/14.
//

import Foundation
import UIKit

protocol welcomeViewObjectDelegateProtocol:AnyObject {
    /// ラベルアニメーション実行時のデリゲートメソッド
    /// - Parameters:
    ///   - fadeInLabel: フェードインアニメーション適用ラベル
    ///   - typingLabel: タイピングアニメーション適用ラベル
    func animationLabel(fadeInLabel:UILabel,typingLabel:CLTypingLabel)
}

protocol welcomeViewDelegateProtocol:AnyObject {
    
    /// UIViewアニメーション実行時のデリゲートメソッド
    /// - Parameter UIview: Self
    func UIViewAnimateStart(UIview:UIView)
}

class initialSettingWelcomeView:UIView {
    ///デリゲート変数に値(self)が入った時点で処理実行
    weak var delegateanimationLabel:welcomeViewObjectDelegateProtocol?{
        didSet {
            animationLabel(self)
        }
    }
    ///デリゲート変数に値(self)が入った時点で処理実行
    weak var delegateUIViewAnimate:welcomeViewDelegateProtocol?{
        didSet {
            UIViewAnimateStart(self)
        }
    }
    /// UIViewのフェードインアニメーションを開始するためのクロージャー。
    /// - Parameter welcomeView: initialSettingWelcomeViewインスタンス
    let UIViewAnimateStart = { (welcomeView: initialSettingWelcomeView) in
        welcomeView.delegateUIViewAnimate?.UIViewAnimateStart(UIview: welcomeView)
    }
    /// ラベルのフェードインアニメーションを開始するためのクロージャー。
    /// - Parameter welcomeView: initialSettingWelcomeViewインスタンス
    let animationLabel = { (welcomeView: initialSettingWelcomeView) in
        welcomeView.delegateanimationLabel?.animationLabel(fadeInLabel: welcomeView.welcomeMessageLabel, typingLabel: welcomeView.welcomeMessageTypingLabel)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        autoLayoutSetup()
        autoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let welcomeMessageLabel:UILabel = {
        let welcomeMassage = UILabel()
        welcomeMassage.text = "ようこそ"
        welcomeMassage.font = UIFont.systemFont(ofSize: 30)
        welcomeMassage.textAlignment = .center
        welcomeMassage.adjustsFontSizeToFitWidth = true
        welcomeMassage.textColor = .black
        welcomeMassage.alpha = 0.0
        return welcomeMassage
    }()

    let welcomeMessageTypingLabel:CLTypingLabel = {
        let welcomeMassage = CLTypingLabel()
        welcomeMassage.font = UIFont.systemFont(ofSize: 30)
        welcomeMassage.textAlignment = .center
        welcomeMassage.adjustsFontSizeToFitWidth = true
        welcomeMassage.textColor = .black
        return welcomeMassage
    }()
    
    /// レイアウト全般処理
    func autoLayoutSetup() {
        addSubview(welcomeMessageLabel)
        addSubview(welcomeMessageTypingLabel)
        welcomeMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeMessageTypingLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    /// オートレイアウト制約処理
    func autoLayout() {
        welcomeMessageTypingLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        welcomeMessageTypingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        welcomeMessageTypingLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        welcomeMessageTypingLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.05).isActive = true
        welcomeMessageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        welcomeMessageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        welcomeMessageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        welcomeMessageLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.05).isActive = true
    }
}



