//
//  initialSettingFinalConfirmView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/05/31.
//

import Foundation
import UIKit

///カスタムラベル
class finalConfirmCustomLabel:UILabel {
    
    init() {
        super.init(frame: .zero)
        setting()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///レイアウト設定
    private func setting() {
        self.textColor = UIColor.black
        self.backgroundColor = .clear
        self.font = UIFont.systemFont(ofSize: 50)
        self.textAlignment = NSTextAlignment.center
        self.adjustsFontSizeToFitWidth = true
    }
}
///性別画像Viewカスタムクラス
class finalConfirmCustomGenderImageView:UIImageView {
    init() {
        super.init(image: nil) // 親クラスの指定イニシャライザを呼び出す
        setting()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///レイアウト設定
    func setting() {
        self.contentMode = .scaleAspectFit
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.clear.cgColor
    }
}
///決定ボタンプロトコル
protocol initialSettingFinalConfirmViewDelegate:AnyObject {
    func decisionButtonTappedAction(initialSettingFinalConfirmView:initialSettingFinalConfirmView)
}

///メインクラス
class initialSettingFinalConfirmView:UIView {
    ///プロファイル受け渡し用変数
    var PROFILEINFODATA = initialProfileInfo()
    ///最終確認案内ラベル
    let finalConfirmInfo:finalConfirmCustomLabel = finalConfirmCustomLabel()
    ///最終確認性別画像
    var finalConfirmGenderImageView:finalConfirmCustomGenderImageView = finalConfirmCustomGenderImageView()
    ///最終確認性別ラベル
    var finalConfirmGenderLabel:finalConfirmCustomLabel = finalConfirmCustomLabel()
    ///最終確認生年月日ラベル
    var finalConfirmBirthLabel:finalConfirmCustomLabel = finalConfirmCustomLabel()
    ///最終確認ニックネームラベル
    var finalConfirmNicknameLabel:finalConfirmCustomLabel = finalConfirmCustomLabel()
    ///年齢・性別変更不可ラベル
    var finalConfirmCannotChanged:finalConfirmCustomLabel = finalConfirmCustomLabel()
    ///デリゲート変数
    weak var delegate:initialSettingFinalConfirmViewDelegate?
    ///決定ボタン
    let decisionButton:UIButton = {
       let returnButton = UIButton()
        returnButton.backgroundColor = .clear
        returnButton.addTarget(self, action: #selector(dicisionButtontapped(_:)), for: .touchUpInside)
        return returnButton
    }()
    
    ///決定ボタン押下時の挙動デリゲート
    @objc func dicisionButtontapped(_ sender: UIButton){
        if delegate != nil {
            self.delegate?.decisionButtonTappedAction(initialSettingFinalConfirmView: self)
        }
    }
    ///決定ImageView
    let decisionImageView:UIImageView = {
        let ImageView = UIImageView()
        ImageView.contentMode = .scaleAspectFit
        ImageView.backgroundColor = .clear
        ImageView.layer.masksToBounds = true
        ImageView.image = UIImage(named: "decisionImage")
        return ImageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        viewSetUp()
        viewLayoutSetUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        ///テキストおよび画像レイアウト変更
        switch PROFILEINFODATA.gender! {
        case .female:
            finalConfirmGenderImageView.image = UIImage(named: "Female")
            finalConfirmGenderLabel.text = "女性"
        case .male:
            finalConfirmGenderImageView.image = UIImage(named: "Male")
            finalConfirmGenderLabel.text = "男性"
        case .none:
            finalConfirmGenderImageView.image = UIImage(named: "Unknown")
            finalConfirmGenderLabel.text = "選択しない"
        }
        finalConfirmBirthLabel.text = PROFILEINFODATA.Age!
        finalConfirmNicknameLabel.text = PROFILEINFODATA.nickName!
    }
}


extension initialSettingFinalConfirmView {
    func viewSetUp() {
        ///背景画像設定
        backGroundViewImageSetUp(imageName: "gemderSelectBack")
        ///案内ラベルセットアップ
        finalConfirmInfo.text = "準備はいいですか？"
        finalConfirmInfo.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        ///警告ラベルセットアップ
        finalConfirmCannotChanged.text = "※性別は後から変更することができません"
        finalConfirmCannotChanged.textColor = UIColor(red: 1, green: 0.2, blue: 0.2, alpha: 0.7)
        
        self.addSubview(finalConfirmInfo)
        self.addSubview(finalConfirmGenderImageView)
        self.addSubview(finalConfirmGenderLabel)
        self.addSubview(finalConfirmBirthLabel)
        self.addSubview(finalConfirmNicknameLabel)
        self.addSubview(finalConfirmCannotChanged)
        self.addSubview(decisionImageView)
        self.addSubview(decisionButton)
        
        finalConfirmInfo.translatesAutoresizingMaskIntoConstraints = false
        finalConfirmGenderImageView.translatesAutoresizingMaskIntoConstraints = false
        finalConfirmGenderLabel.translatesAutoresizingMaskIntoConstraints = false
        finalConfirmBirthLabel.translatesAutoresizingMaskIntoConstraints = false
        finalConfirmNicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        finalConfirmCannotChanged.translatesAutoresizingMaskIntoConstraints = false
        decisionImageView.translatesAutoresizingMaskIntoConstraints = false
        decisionButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func viewLayoutSetUp() {
        ///ニックネーム入力案内ラベル
        finalConfirmInfo.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        finalConfirmInfo.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.1).isActive = true
        finalConfirmInfo.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
        finalConfirmInfo.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor,constant: 25).isActive = true
        ///真ん中から上
        finalConfirmBirthLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        finalConfirmBirthLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        finalConfirmBirthLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        finalConfirmBirthLabel.heightAnchor.constraint(equalTo: self.heightAnchor,multiplier: 0.1).isActive = true
        
        
        finalConfirmGenderLabel.bottomAnchor.constraint(equalTo: finalConfirmBirthLabel.topAnchor).isActive = true
        finalConfirmGenderLabel.heightAnchor.constraint(equalTo: finalConfirmBirthLabel.heightAnchor).isActive = true
        finalConfirmGenderLabel.leadingAnchor.constraint(equalTo: finalConfirmBirthLabel.leadingAnchor).isActive = true
        finalConfirmGenderLabel.trailingAnchor.constraint(equalTo: finalConfirmBirthLabel.trailingAnchor).isActive = true
        
        finalConfirmGenderImageView.bottomAnchor.constraint(equalTo: finalConfirmGenderLabel.topAnchor).isActive = true
        finalConfirmGenderImageView.heightAnchor.constraint(equalTo: finalConfirmBirthLabel.heightAnchor).isActive = true
        finalConfirmGenderImageView.leadingAnchor.constraint(equalTo: finalConfirmBirthLabel.leadingAnchor).isActive = true
        finalConfirmGenderImageView.trailingAnchor.constraint(equalTo: finalConfirmBirthLabel.trailingAnchor).isActive = true

        finalConfirmNicknameLabel.topAnchor.constraint(equalTo: finalConfirmBirthLabel.bottomAnchor).isActive = true
        finalConfirmNicknameLabel.heightAnchor.constraint(equalTo: finalConfirmBirthLabel.heightAnchor).isActive = true
        finalConfirmNicknameLabel.leadingAnchor.constraint(equalTo: finalConfirmBirthLabel.leadingAnchor).isActive = true
        finalConfirmNicknameLabel.trailingAnchor.constraint(equalTo: finalConfirmBirthLabel.trailingAnchor).isActive = true
        
        finalConfirmCannotChanged.topAnchor.constraint(equalTo: finalConfirmNicknameLabel.bottomAnchor).isActive = true
        finalConfirmCannotChanged.heightAnchor.constraint(equalTo: finalConfirmBirthLabel.heightAnchor,multiplier: 0.5).isActive = true
        finalConfirmCannotChanged.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 10).isActive = true
        finalConfirmCannotChanged.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -10).isActive = true
        
        decisionImageView.topAnchor.constraint(equalTo: finalConfirmCannotChanged.bottomAnchor,constant: 10).isActive = true
        decisionImageView.centerXAnchor.constraint(equalTo: finalConfirmCannotChanged.centerXAnchor).isActive = true
        decisionImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4).isActive = true
        decisionImageView.heightAnchor.constraint(equalTo: self.heightAnchor,multiplier: 0.1).isActive = true
        
        decisionButton.centerXAnchor.constraint(equalTo: decisionImageView.centerXAnchor).isActive = true
        decisionButton.centerYAnchor.constraint(equalTo: decisionImageView.centerYAnchor).isActive = true
        decisionButton.widthAnchor.constraint(equalTo: decisionImageView.widthAnchor).isActive = true
        decisionButton.heightAnchor.constraint(equalTo: decisionImageView.heightAnchor).isActive = true
    }
}
