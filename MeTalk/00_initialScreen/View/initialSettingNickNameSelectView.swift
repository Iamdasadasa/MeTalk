//
//  initialSettingNickNameSelectView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/05/30.
//

import Foundation
import UIKit

///メインクラスプロトコル
protocol initialSettingNickNameSelectViewDelegate:AnyObject {
    func decisionButtonTappedAction(ageSelectionView:initialSettingNickNameSelectView)
}
///メインクラス
class initialSettingNickNameSelectView:UIView {
    ///ニックネーム入力案内ラベル
    let nickNameInputInfoLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = "ニックネームを決めましょう"
        returnLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        returnLabel.backgroundColor = .clear
        returnLabel.font = UIFont.systemFont(ofSize: 50)
        returnLabel.textAlignment = NSTextAlignment.center
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    ///ニックネーム下線画像
    let nickNameUnderLineImageView:UIImageView = UIImageView(image: UIImage(named: "NickName_UnderLine"))
    ///ニックネーム入力テキストフィールド
    let nickNameInputTextField:nickNameCustomTextField = nickNameCustomTextField()
    ///デリゲート用変数
    weak var delegate:initialSettingNickNameSelectViewDelegate?
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
            self.delegate?.decisionButtonTappedAction(ageSelectionView: self)
        }
    }
    ///決定画像
    let decisionImageView:UIImageView = {
        let ImageView = UIImageView()
        ImageView.contentMode = .scaleAspectFit
        ImageView.backgroundColor = .clear
        ImageView.layer.masksToBounds = true
        ImageView.image = UIImage(named: "decisionImage")
        return ImageView
    }()
    
    ///ビューの初期化
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewSetUp()
        viewLayoutSetUp()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        ///オブジェクトの大きさに合わせて文字サイズを変更
        let fontSize = sizeAdjust.objecFontSizeAutoResize(MaxCharacterDigit: 5, objectWidth: nickNameInputTextField.bounds.width)
        self.nickNameInputTextField.font = UIFont.systemFont(ofSize: fontSize)
    }
}

extension initialSettingNickNameSelectView{
    func viewSetUp() {
        ///はじめは決定ボタンは表示しない
        self.decisionButton.isEnabled = false
        self.decisionImageView.isHidden = true
        ///背景画像設定
        backGroundViewImageSetUp(imageName: "gemderSelectBack")
        
        self.addSubview(nickNameInputInfoLabel)
        self.addSubview(nickNameInputTextField)
        self.addSubview(nickNameUnderLineImageView)
        self.addSubview(decisionImageView)
        self.addSubview(decisionButton)
        
        nickNameInputInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        nickNameInputTextField.translatesAutoresizingMaskIntoConstraints = false
        nickNameUnderLineImageView.translatesAutoresizingMaskIntoConstraints = false
        decisionImageView.translatesAutoresizingMaskIntoConstraints = false
        decisionButton.translatesAutoresizingMaskIntoConstraints = false
        
        ///オブザーバー（テキストフィールドの文字が変更されたタイミング）
        NotificationCenter.default.addObserver(self,
          selector: #selector(textFieldDidChange(notification:)),
          name: UITextField.textDidChangeNotification,
          object: nickNameInputTextField)
    }
    
    func viewLayoutSetUp() {
        ///ニックネーム入力案内ラベル
        nickNameInputInfoLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        nickNameInputInfoLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.1).isActive = true
        nickNameInputInfoLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
        nickNameInputInfoLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor,constant: 25).isActive = true
        ///ニックネーム入力テキストフィールド
        nickNameInputTextField.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        nickNameInputTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        nickNameInputTextField.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        nickNameInputTextField.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.09).isActive = true
        ///ニックネーム下線画像
        nickNameUnderLineImageView.topAnchor.constraint(equalTo: nickNameInputTextField.bottomAnchor).isActive = true
        nickNameUnderLineImageView.centerXAnchor.constraint(equalTo: nickNameInputTextField.centerXAnchor).isActive = true
        nickNameUnderLineImageView.widthAnchor.constraint(equalTo: nickNameInputTextField.widthAnchor).isActive = true
        nickNameUnderLineImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.02).isActive = true
        ///決定画像
        decisionImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        decisionImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4).isActive = true
        decisionImageView.heightAnchor.constraint(equalTo: self.heightAnchor,multiplier: 0.1).isActive = true
        decisionImageView.topAnchor.constraint(equalTo: nickNameUnderLineImageView.bottomAnchor, constant: 25).isActive = true
        ///決定ボタン
        decisionButton.centerXAnchor.constraint(equalTo: decisionImageView.centerXAnchor).isActive = true
        decisionButton.centerYAnchor.constraint(equalTo: decisionImageView.centerYAnchor).isActive = true
        decisionButton.widthAnchor.constraint(equalTo: decisionImageView.widthAnchor).isActive = true
        decisionButton.heightAnchor.constraint(equalTo: decisionImageView.heightAnchor).isActive = true
    }
}

extension initialSettingNickNameSelectView{
    ///    ///リターンボタンを押下したらキーボードがしまわれる処理
    /// - Parameters:
    /// - Returns: none
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nickNameInputTextField.resignFirstResponder()
        return true
    }
    ///    /// 空白の部分をタッチしたらキーボードがしまわれる処理
    /// - Parameters:
    /// - Returns: none
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nickNameInputTextField.endEditing(true)
    }
    ///    ///オブザーバー処理
    /// - Parameters:
    ///   - notification: ニックネーム入力テキストフィールド
    /// - Returns: none
    @objc func textFieldDidChange(notification: NSNotification) {
        ///文字制限処理(10文字)
        let textField = notification.object as! nickNameCustomTextField
        if let text = textField.text {

            self.decisionButton.isEnabled = true
            self.decisionImageView.isHidden = false

            if textField.markedTextRange == nil && text.count > 5 {
                textField.text = text.prefix(5).description
            }
        }
        if textField.text == "" {
            self.decisionButton.isEnabled = false
            self.decisionImageView.isHidden = true
        }
    }
}
