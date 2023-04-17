//
//  initialSettingView_Gender.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/04/14.
//

import Foundation
import UIKit

protocol welcomeViewObjectDelegateProtocol:AnyObject {
    func fadeInLabel(fadeInLabel:UILabel)
}

protocol welcomeViewDelegateProtocol:AnyObject {
    func UIViewAnimateStart(UIview:UIView)
}

class initialSettingWelcomeView:UIView {
    
    weak var delegateFadeIn:welcomeViewObjectDelegateProtocol?{
        didSet {
            // ラベルのフェードイン処理を実行する
            fadeInLabelStart(self)
        }
    }
    
    weak var delegateUIViewAnimate:welcomeViewDelegateProtocol?{
        didSet {
            // UIViewのフェードイン処理を実行する
            UIViewAnimateStart(self)
        }
    }
    
    let UIViewAnimateStart = { (welcomeView: initialSettingWelcomeView) in
        welcomeView.delegateUIViewAnimate?.UIViewAnimateStart(UIview: welcomeView)
    }

    let fadeInLabelStart = { (welcomeView: initialSettingWelcomeView) in
        welcomeView.delegateFadeIn?.fadeInLabel(fadeInLabel: welcomeView.welcomeMessageLabel)
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
    ///ボタン・フィールド定義
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
    
    func autoLayoutSetup() {
        addSubview(welcomeMessageLabel)
        welcomeMessageLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func autoLayout() {
        welcomeMessageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        welcomeMessageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        welcomeMessageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        welcomeMessageLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.05).isActive = true
    }
    
}



