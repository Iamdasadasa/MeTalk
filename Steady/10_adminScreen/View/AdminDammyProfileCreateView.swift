//
//  AdminDammyProfileCreateView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/11/07.
//

import Foundation
import UIKit
protocol AdminDammyProfileCreateViewDelegate:AnyObject{
    func buckButtonTappedDelegate()
    func profileImageButtonTappedDelegate()
    func keyBoardObserverShowDelegate(Top:CGFloat)
    func keyBoardObserverHideDelegate()
    func d_ProfileCreatedecisionButtontappedAction()
}

class AdminDammyProfileCreateView:UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        userForLayoutChange()
        autoLayoutSetUp()
        autoLayout()
        viewSetUp()
    }
    
    //※各定義※
    weak var delegate:AdminDammyProfileCreateViewDelegate?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //※layoutSubviews レイアウト描写が更新された後※
    override func layoutSubviews() {
        super.layoutSubviews()
        ///プロフィール画像を丸くする処理
        profileImageButton.layer.cornerRadius = profileImageButton.bounds.height/2
        
        ///文字サイズを横幅いっぱいまで拡大
        profileTitleLabel.font = profileTitleLabel.font.withSize(profileTitleLabel.bounds.height)
        nickNameTopLabel.font = nickNameTopLabel.font.withSize(nickNameTopLabel.bounds.width * 0.07)
        
        shadowView.shadowSetting(offset: .buttomReft)
        
        medianValueGet()
    }
    var objectMedianValue:CGFloat?
    ///各変更Item
    let nickNameItemView = ProfileChildView()
    let AboutMeItemView = ProfileChildView()
    let areaItemView = ProfileChildView()
    let birthItemView = ProfileChildView()
    let genderItemView = ProfileChildView()
    ///ダミープロフィール作成タイトルラベル
    let profileTitleLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = "┃ダミープロフィール作成"
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()

    ///ダミープロフィール画像ボタン
    let profileImageButton:UIButton = {
        let returnUIButton = UIButton()
        returnUIButton.layer.borderWidth = 1
        returnUIButton.clipsToBounds = true
        returnUIButton.layer.borderColor = UIColor.gray.cgColor
        returnUIButton.addTarget(self, action: #selector(profileImageButtonTapped), for: .touchUpInside)
        return returnUIButton
    }()
    
    ///決定ボタン
    let d_ProfileCreatedecisionButton:UIButton = {
       let returnButton = UIButton()
        returnButton.backgroundColor = .clear
        returnButton.setTitle("送信", for: .normal)
        returnButton.setTitleColor(UIColor.red, for: .normal)
        returnButton.addTarget(self, action: #selector(d_ProfileCreatedecisionButtontapped(_:)), for: .touchUpInside)
        return returnButton
    }()
    
    ///陰影View
    let shadowView = ShadowBaseView()
    
    ///決定ボタン押下時の挙動デリゲート
    @objc func d_ProfileCreatedecisionButtontapped(_ sender: UIButton){
        print("押下されました")
        if delegate != nil {
            self.delegate?.d_ProfileCreatedecisionButtontappedAction()
        }
    }

    @objc func profileImageButtonTapped(){
        delegate?.profileImageButtonTappedDelegate()
    }
    
    ///ニックネーム表示ラベル
    let nickNameTopLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    func autoLayoutSetUp() {
        ///Viewの追加
        addSubview(nickNameItemView)
        addSubview(AboutMeItemView)
        addSubview(areaItemView)
        addSubview(birthItemView)
        addSubview(genderItemView)
        addSubview(profileTitleLabel)
        addSubview(profileImageButton)
        addSubview(nickNameTopLabel)
        addSubview(shadowView)
        addSubview(d_ProfileCreatedecisionButton)
        ///競合をなくす
        nickNameItemView.translatesAutoresizingMaskIntoConstraints = false
        AboutMeItemView.translatesAutoresizingMaskIntoConstraints = false
        areaItemView.translatesAutoresizingMaskIntoConstraints = false
        birthItemView.translatesAutoresizingMaskIntoConstraints = false
        genderItemView.translatesAutoresizingMaskIntoConstraints = false
        profileTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        profileImageButton.translatesAutoresizingMaskIntoConstraints = false
        nickNameTopLabel.translatesAutoresizingMaskIntoConstraints = false
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        d_ProfileCreatedecisionButton.translatesAutoresizingMaskIntoConstraints = false
        
    }


    func autoLayout() {
        profileImageButton.topAnchor.constraint(equalTo: self.profileTitleLabel.bottomAnchor, constant: 25).isActive = true
        profileImageButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        profileImageButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.125).isActive = true
        profileImageButton.widthAnchor.constraint(equalTo: self.profileImageButton.heightAnchor).isActive = true
        
        nickNameTopLabel.topAnchor.constraint(equalTo: self.profileImageButton.topAnchor).isActive = true
        nickNameTopLabel.leadingAnchor.constraint(equalTo: self.profileImageButton.trailingAnchor, constant: 10).isActive = true
        nickNameTopLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        nickNameTopLabel.bottomAnchor.constraint(equalTo: self.profileImageButton.bottomAnchor).isActive = true
        
        nickNameItemView.topAnchor.constraint(equalTo: self.profileImageButton.bottomAnchor,constant: 40).isActive = true
        nickNameItemView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        nickNameItemView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        nickNameItemView.heightAnchor.constraint(equalTo: self.profileImageButton.heightAnchor,multiplier: 0.6).isActive = true
        
        AboutMeItemView.topAnchor.constraint(equalTo: self.nickNameItemView.bottomAnchor,constant: 10).isActive = true
        AboutMeItemView.leadingAnchor.constraint(equalTo: self.nickNameItemView.leadingAnchor).isActive = true
        AboutMeItemView.trailingAnchor.constraint(equalTo: self.nickNameItemView.trailingAnchor).isActive = true
        AboutMeItemView.heightAnchor.constraint(equalTo: self.nickNameItemView.heightAnchor).isActive = true
        
        areaItemView.topAnchor.constraint(equalTo: self.AboutMeItemView.bottomAnchor,constant: 10).isActive = true
        areaItemView.leadingAnchor.constraint(equalTo: self.nickNameItemView.leadingAnchor).isActive = true
        areaItemView.trailingAnchor.constraint(equalTo: self.nickNameItemView.trailingAnchor).isActive = true
        areaItemView.heightAnchor.constraint(equalTo: self.nickNameItemView.heightAnchor).isActive = true
        
        birthItemView.topAnchor.constraint(equalTo: self.areaItemView.bottomAnchor,constant: 10).isActive = true
        birthItemView.leadingAnchor.constraint(equalTo: self.areaItemView.leadingAnchor).isActive = true
        birthItemView.trailingAnchor.constraint(equalTo: self.areaItemView.trailingAnchor).isActive = true
        birthItemView.heightAnchor.constraint(equalTo: self.areaItemView.heightAnchor).isActive = true
        
        genderItemView.topAnchor.constraint(equalTo: self.birthItemView.bottomAnchor,constant: 10).isActive = true
        genderItemView.leadingAnchor.constraint(equalTo: self.birthItemView.leadingAnchor).isActive = true
        genderItemView.trailingAnchor.constraint(equalTo: self.birthItemView.trailingAnchor).isActive = true
        genderItemView.heightAnchor.constraint(equalTo: self.birthItemView.heightAnchor).isActive = true
        
        d_ProfileCreatedecisionButton.topAnchor.constraint(equalTo: self.genderItemView.bottomAnchor,constant: 10).isActive = true
        d_ProfileCreatedecisionButton.widthAnchor.constraint(equalTo: genderItemView.widthAnchor, multiplier: 0.5).isActive = true
        d_ProfileCreatedecisionButton.centerXAnchor.constraint(equalTo: genderItemView.centerXAnchor).isActive = true
        d_ProfileCreatedecisionButton.heightAnchor.constraint(equalTo: genderItemView.heightAnchor).isActive = true
        
        shadowView.topAnchor.constraint(equalTo: d_ProfileCreatedecisionButton.topAnchor).isActive = true
        shadowView.leadingAnchor.constraint(equalTo: d_ProfileCreatedecisionButton.leadingAnchor).isActive = true
        shadowView.trailingAnchor.constraint(equalTo: d_ProfileCreatedecisionButton.trailingAnchor).isActive = true
        shadowView.bottomAnchor.constraint(equalTo: d_ProfileCreatedecisionButton.bottomAnchor).isActive = true
    }
    
}

extension AdminDammyProfileCreateView{
    ///線を引くX座標の特定
    func medianValueGet(){
        self.objectMedianValue = self.profileTitleLabel.frame.maxY
    }

    override func draw(_ rect: CGRect) {
        // オブジェクト間の直線 -------------------------------------
        guard let objectMedianValue = self.objectMedianValue else { return }
        // UIBezierPath のインスタンス生成
        let line = UIBezierPath()
        // 起点
        line.move(to: CGPoint(x: self.frame.minX, y: objectMedianValue))
        // 帰着点
        line.addLine(to: CGPoint(x: self.frame.maxX, y: objectMedianValue))
        // 色の設定
        UIColor.gray.setStroke()
        // ライン幅（適切な幅を設定）
        line.lineWidth = 1.0
        // 描画
        line.stroke()
    }
}


///Viewセットアップ
extension AdminDammyProfileCreateView{
    func viewSetUp(){
        ///キーボード表示監視
        Foundation.NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        ///キーボード非表示監視
        Foundation.NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        ///タイトルセットアップ
        self.nickNameItemView.TitleLabel.text = "┃ニックネーム"
        self.AboutMeItemView.TitleLabel.text = "┃ひとこと"
        self.areaItemView.TitleLabel.text = "┃住まい"
        self.birthItemView.TitleLabel.text = "┃誕生日"
        self.genderItemView.TitleLabel.text = "┃性別"

        ///View判断タグセットアップ
        self.nickNameItemView.tag = 1
        self.AboutMeItemView.tag = 2
        self.areaItemView.tag = 3
        self.birthItemView.tag = 4
        self.genderItemView.tag = 5
        
        ///各ボタン有効化
        self.nickNameItemView.selfClearButton.isEnabled = true
        self.AboutMeItemView.selfClearButton.isEnabled = true
        self.areaItemView.selfClearButton.isEnabled = true
        self.birthItemView.selfClearButton.isEnabled = true
        self.genderItemView.selfClearButton.isEnabled = true
        
        //性別初期値
        self.genderItemView.valueLabel.text = "2"
    }
    ///表示するユーザーの種類によって画面のレイアウトを変更
    func userForLayoutChange() {
        ///タイトルラベル共通
        addSubview(profileTitleLabel)
        profileTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        ///プロフィールタイトルラベル
        self.profileTitleLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        self.profileTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        self.profileTitleLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.05).isActive = true
        self.profileTitleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
    }
    ///キーボード表示時
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardTopY = keyboardFrame.origin.y
            // キーボードの上部の位置を取得
            delegate?.keyBoardObserverShowDelegate(Top: keyboardTopY)
        }
    }
    ///キーボード非表示時
    @objc func keyboardWillHide(_ notification: Notification) {
        delegate?.keyBoardObserverHideDelegate()
    }
    ///戻るボタンタップ時のアクション
    @objc func backButtonTapped() {
        delegate?.buckButtonTappedDelegate()
    }
}
