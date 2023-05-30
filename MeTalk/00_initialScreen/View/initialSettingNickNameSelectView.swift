//
//  initialSettingNickNameSelectView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/05/30.
//

import Foundation
import UIKit
///ニックネーム入力テキストフィールド
class nickNameCustomTextField:UITextField{
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setting()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///テキストフィールドの修飾
    private func setting() {
        self.placeholder = "最大5文字"
        self.borderStyle = .roundedRect
        self.textColor = .black
        self.borderStyle = .none
        self.backgroundColor = .clear
        self.textAlignment = .center
//        self.adjustsFontSizeToFitWidth = true
    }
}
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
    ///ニックネーム下線イメージビュー
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
    ///決定ラベル
    let decisionLabel:UILabel = {
        let label = UILabel()
        label.text = "決定"
        label.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
        label.backgroundColor = .white
        label.font = UIFont.systemFont(ofSize: 25)
        label.textAlignment = NSTextAlignment.center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
    
    
    ///ビューの初期化
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewSetUp()
        viewLayoutSetUp()
    }
    ///コードから生成されるビューに対応する初期化メソッド
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewSetUp()
        viewLayoutSetUp()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textFieldFontSizeAutoResize()
    }
}

extension initialSettingNickNameSelectView{
    func viewSetUp() {
        ///背景画像設定
        backGroundViewImageSetUp(imageName: "gemderSelectBack")
        
        self.addSubview(nickNameInputInfoLabel)
        self.addSubview(nickNameInputTextField)
        self.addSubview(nickNameUnderLineImageView)
        self.addSubview(decisionLabel)
        self.addSubview(decisionButton)
        
        nickNameInputInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        nickNameInputTextField.translatesAutoresizingMaskIntoConstraints = false
        nickNameUnderLineImageView.translatesAutoresizingMaskIntoConstraints = false
        decisionLabel.translatesAutoresizingMaskIntoConstraints = false
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
        
        nickNameInputTextField.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        nickNameInputTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        nickNameInputTextField.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        nickNameInputTextField.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.09).isActive = true
        
        nickNameUnderLineImageView.topAnchor.constraint(equalTo: nickNameInputTextField.bottomAnchor).isActive = true
        nickNameUnderLineImageView.centerXAnchor.constraint(equalTo: nickNameInputTextField.centerXAnchor).isActive = true
        nickNameUnderLineImageView.widthAnchor.constraint(equalTo: nickNameInputTextField.widthAnchor).isActive = true
        nickNameUnderLineImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.02).isActive = true
        

        decisionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        decisionLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4).isActive = true
        decisionLabel.heightAnchor.constraint(equalTo: self.heightAnchor,multiplier: 0.1).isActive = true
        decisionLabel.topAnchor.constraint(equalTo: nickNameUnderLineImageView.bottomAnchor, constant: 25).isActive = true
        
        decisionButton.centerXAnchor.constraint(equalTo: self.decisionLabel.centerXAnchor).isActive = true
        decisionButton.centerYAnchor.constraint(equalTo: self.decisionLabel.centerYAnchor).isActive = true
        

    }
    
}

extension initialSettingNickNameSelectView{
    
    func textFieldFontSizeAutoResize() {
        // 最大文字サイズの計算
        let textFieldWidth = self.nickNameInputTextField.bounds.width
        let characterWidth = textFieldWidth / CGFloat(5)
        let maximumFontSize = UIFont.systemFont(ofSize: 1).pointSize * characterWidth
        self.nickNameInputTextField.font = UIFont.systemFont(ofSize: maximumFontSize)
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
            self.decisionLabel.isHidden = false

            if textField.markedTextRange == nil && text.count > 5 {
                textField.text = text.prefix(5).description
            }
        }
        if textField.text == "" {
            self.decisionButton.isEnabled = false
            self.decisionLabel.isHidden = true
        }
    }
}
