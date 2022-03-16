//
//  SignUpView.swift
//  ClubSunriseCoast
//
//  Created by KOJIRO MARUYAMA on 2021/04/13.
//

import UIKit
protocol  NickNameTextFieldModalViewDelegateProtcol:AnyObject {
    func dicisionButtonTappedAction(button:UIButton,view: NickNameTextFieldModalView)
    func closeButtonTappedAction(button:UIButton,view:NickNameTextFieldModalView)
}

class   NickNameTextFieldModalView:UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        autoLayoutSetUp()
        autoLayout()
    }
//※初期化処理※
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//※各定義※
    ///変数宣言
    weak var delegate: NickNameTextFieldModalViewDelegateProtcol?
    ///ボタン・フィールド定義
    ///
    ///項目変更タイトルラベル
    let itemTitleLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = "ニックネーム"
        returnLabel.textColor = .white
        returnLabel.backgroundColor = .clear
        returnLabel.font = UIFont.systemFont(ofSize: 15)
        returnLabel.textAlignment = NSTextAlignment.left
        return returnLabel
    }()
    ///項目テキストフィールド
    let itemTextField:UITextField = {
        let returnTextField = UITextField()
        returnTextField.borderStyle = .roundedRect
        returnTextField.textColor = .white
        returnTextField.placeholder = "10文字以内"
        returnTextField.borderStyle = .none
        returnTextField.clearButtonMode = .always
        returnTextField.tag = 1
        return returnTextField
    }()
    ///決定ボタン
    let decisionButton:UIButton = {
        let returnButton = UIButton()
        returnButton.setTitle("決定", for: .normal)
        returnButton.setTitleColor(UIColor.white, for: .normal)
        returnButton.tag = 1
        returnButton.backgroundColor = .orange
        returnButton.addTarget(self, action: #selector(butttonClicked(_:)), for: UIControl.Event.touchUpInside)
        return returnButton
    }()
    /// 決定ボタンが押下された際の挙動
    @objc func butttonClicked(_ sender: UIButton) {
        if let delegate = delegate {
            self.delegate?.dicisionButtonTappedAction(button: sender, view: self)
        }
    }
    
    ///モーダルを閉じるボタン
    let CloseModalButton:UIButton = {
        let returnButton = UIButton()
        returnButton.addTarget(self, action: #selector(closeButttonClicked(_:)), for: UIControl.Event.touchUpInside)
        return returnButton
    }()
    /// クローズボタンが押下された際の挙動
    @objc func closeButttonClicked(_ sender: UIButton) {
        if let delegate = delegate {
            self.delegate?.closeButtonTappedAction(button: sender, view: self)
        }
    }

    
//※レイアウト設定※
    func autoLayoutSetUp() {
        ///各オブジェクトをViewに追加
        addSubview(itemTitleLabel)
        addSubview(itemTextField)
        addSubview(decisionButton)
        addSubview(CloseModalButton)


        ///UIオートレイアウトと競合させない処理
        itemTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        itemTextField.translatesAutoresizingMaskIntoConstraints = false
        decisionButton.translatesAutoresizingMaskIntoConstraints = false
        CloseModalButton.translatesAutoresizingMaskIntoConstraints = false
    }
//※レイアウト※
    func autoLayout() {
        ///項目変更タイトルラベル
        itemTitleLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        itemTitleLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.03).isActive = true
        itemTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 30).isActive = true
        itemTitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        ///項目変更テキストフィールド
        itemTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        itemTextField.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.05).isActive = true
        itemTextField.topAnchor.constraint(equalTo: self.itemTitleLabel.bottomAnchor).isActive = true
        itemTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        ///決定ボタン
        decisionButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        decisionButton.heightAnchor.constraint(equalTo: itemTextField.heightAnchor).isActive = true
        decisionButton.topAnchor.constraint(equalTo: self.itemTextField.bottomAnchor, constant: 10).isActive = true
        decisionButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        ///閉じるボタン
        CloseModalButton.heightAnchor.constraint(equalTo: self.itemTitleLabel.heightAnchor).isActive = true
        CloseModalButton.widthAnchor.constraint(equalTo: self.CloseModalButton.heightAnchor).isActive = true
        CloseModalButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        CloseModalButton.topAnchor.constraint(equalTo: self.itemTitleLabel.topAnchor).isActive = true
    }
}

extension NickNameTextFieldModalView{
    ///テキストフィールドの枠線を自作
    override func draw(_ rect: CGRect) {
        // UIBezierPath のインスタンス生成
        let line = UIBezierPath();
        // 起点
        line.move(to: CGPoint(x: self.itemTextField.frame.minX, y: self.itemTextField.frame.maxY));
        // 帰着点
        line.addLine(to: CGPoint(x: self.itemTextField.frame.maxX, y: self.itemTextField.frame.maxY));
        // ラインを結ぶ
        line.close()
        // 色の設定
        UIColor.gray.setStroke()
//        UIColor.init(red: 50, green: 50, blue: 50, alpha: 100).setStroke()
        // ライン幅
        line.lineWidth = 1
        // 描画
        line.stroke();
    }
}

