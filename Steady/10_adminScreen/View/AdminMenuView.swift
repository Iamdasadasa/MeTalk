//
//  AdminMenuView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/10/18.
//

import Foundation
import UIKit

protocol AdminMenuProtocol:AnyObject {
    func violationConfirmButtontappedAction()
    func chatConfirmButtontappedAction()
    func createProfileButtontappedAction()
    func dammyChatButtontappedAction()
    func dammyUserUpdateTimeReset()
}

class AdminMenuView:UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        autoLayoutSetUp()
        autoLayout()
    }
    
    var BaseLabel =  { (title:String) in    ///ラベルの雛形
        var baseLabel:UILabel = UILabel()
        baseLabel.text = title
        baseLabel.textColor = .gray
        baseLabel.adjustsFontSizeToFitWidth = true
        return baseLabel
    }
    lazy var subscribeLabel:UILabel = {    ///登録者数ラベル
        return  BaseLabel("登録者数")
    }()
    var subscribeShadowView:ShadowBaseView = ShadowBaseView()   ///登録者数ラベルの陰影用View

    lazy var totalChatLabel:UILabel = { ///総チャット数ラベル
        return BaseLabel("総チャットルーム数")
    }()

    var totalChatShadowView:ShadowBaseView = ShadowBaseView()   ///総チャット数ラベルの陰影用View
    
    lazy var totalContentsSizeLabel:UILabel = {
        return BaseLabel("用途未定")
    }()
    var totalContentsSizeShadowView:ShadowBaseView = ShadowBaseView() 

    var adminMenuLabel: UILabel = {   ///管理者メニューラベル
        let UIlabel = UILabel()
        UIlabel.text = "管理者メニュー"
        UIlabel.textColor = .black
        UIlabel.backgroundColor = .white
        return UIlabel
    }()
    let violationConfirmButton:UIButton = { ///違反確認ボタン
        let Button = UIButton()
        Button.setTitle("違反確認", for: .normal)
        Button.setTitleColor(UIColor.gray, for: .normal)
        Button.backgroundColor = .white
        Button.contentHorizontalAlignment = .left
        Button.addTarget(self, action: #selector(violationConfirmButtontapped(_:)), for: .touchUpInside)
        return Button
    }()
    
    ///違反確認ボタン押下時の挙動デリゲート
    @objc func violationConfirmButtontapped(_ sender: UIButton){
        delegate?.violationConfirmButtontappedAction()
    }
    
    let chatConfirmButton:UIButton = { ///チャット確認ボタン
        let Button = UIButton()
        Button.setTitle("チャット確認", for: .normal)
        Button.setTitleColor(UIColor.gray, for: .normal)
        Button.backgroundColor = .white
        Button.contentHorizontalAlignment = .left
        Button.addTarget(self, action: #selector(chatConfirmButtontapped(_:)), for: .touchUpInside)
        return Button
    }()
    
    ///チャット確認ボタン押下時の挙動デリゲート
    @objc func chatConfirmButtontapped(_ sender: UIButton){
        delegate?.chatConfirmButtontappedAction()
    }
    
    ///UID入力テキストフィールド
    let UIDInputTxtField:UITextField = {
        let UITextField = UITextField()
        UITextField.borderStyle = .roundedRect
        UITextField.placeholder = "ルームID"
        return UITextField
    }()
    
    let createProfileButton:UIButton = { //ダミープロフィール作成ボタン
        let Button = UIButton()
        Button.setTitle("D_プロフィール作成", for: .normal)
        Button.setTitleColor(UIColor.gray, for: .normal)
        Button.backgroundColor = .white
        Button.contentHorizontalAlignment = .left
        Button.addTarget(self, action: #selector(createProfileButtontapped(_:)), for: .touchUpInside)
        return Button
    }()
    
    ///ダミープロフィール作成ボタン押下時の挙動デリゲート
    @objc func createProfileButtontapped(_ sender: UIButton){
        delegate?.createProfileButtontappedAction()
    }
    
    let dammyChatButton:UIButton = { //ダミーチャットボタン
        let Button = UIButton()
        Button.setTitle("D_チャット", for: .normal)
        Button.setTitleColor(UIColor.gray, for: .normal)
        Button.backgroundColor = .white
        Button.contentHorizontalAlignment = .left
        Button.addTarget(self, action: #selector(dammyChatButtontapped(_:)), for: .touchUpInside)
        return Button
    }()
    
    ///ダミーチャットボタン押下時の挙動デリゲート
    @objc func dammyChatButtontapped(_ sender: UIButton){
        delegate?.dammyChatButtontappedAction()
    }
    
    ///ボタンイメージ
    let buttonImageView01:UIImageView = {
        let uiimageView = UIImageView()
        uiimageView.image = UIImage(named: "rightArrow")
        return uiimageView
    }()
    ///ボタンイメージ
    let buttonImageView02:UIImageView = {
        let uiimageView = UIImageView()
        uiimageView.image = UIImage(named: "rightArrow")
        return uiimageView
    }()
    ///ボタンイメージ
    let buttonImageView03:UIImageView = {
        let uiimageView = UIImageView()
        uiimageView.image = UIImage(named: "rightArrow")
        return uiimageView
    }()
    ///ボタンイメージ
    let buttonImageView04:UIImageView = {
        let uiimageView = UIImageView()
        uiimageView.image = UIImage(named: "rightArrow")
        return uiimageView
    }()
    let dammyUpdateButtonShadowView = ShadowBaseView()
    let userDammyUpdateResetButton:UIButton = {
        let Button = UIButton()
        Button.backgroundColor = .clear
        Button.setTitle("Dユーザー時間更新", for: .normal)
        Button.setTitleColor(UIColor.gray, for: .normal)
        Button.addTarget(self, action: #selector(userDammyUpdateResetButtontapped), for: .touchUpInside)
        return Button
    }()
    
    ///ダミーチャットボタン押下時の挙動デリゲート
    @objc func userDammyUpdateResetButtontapped(_ sender: UIButton){
        delegate?.dammyUserUpdateTimeReset()
    }
    
    ///デリゲート変数
    weak var delegate:AdminMenuProtocol?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subscribeShadowView.shadowSetting(offset: .topRight)
        totalChatShadowView.shadowSetting(offset: .topRight)
        totalContentsSizeShadowView.shadowSetting(offset: .topRight)
        dammyUpdateButtonShadowView.shadowSetting(offset: .topRight)
    }
    
    
    //※レイアウト設定※
    func autoLayoutSetUp(){
        ///各オブジェクトをViewに追加
        addSubview(subscribeShadowView)
        addSubview(subscribeLabel)
        addSubview(totalChatShadowView)
        addSubview(totalChatLabel)
        addSubview(totalContentsSizeShadowView)
        addSubview(totalContentsSizeLabel)
        addSubview(adminMenuLabel)
        addSubview(violationConfirmButton)
        addSubview(chatConfirmButton)
        addSubview(UIDInputTxtField)
        addSubview(createProfileButton)
        addSubview(dammyChatButton)
        addSubview(buttonImageView01)
        addSubview(buttonImageView02)
        addSubview(buttonImageView03)
        addSubview(buttonImageView04)
        addSubview(dammyUpdateButtonShadowView)
        addSubview(userDammyUpdateResetButton)
        
        ///UIオートレイアウトと競合させない処理
        subscribeShadowView.translatesAutoresizingMaskIntoConstraints = false
        subscribeLabel.translatesAutoresizingMaskIntoConstraints = false
        totalChatShadowView.translatesAutoresizingMaskIntoConstraints = false
        totalChatLabel.translatesAutoresizingMaskIntoConstraints = false
        totalContentsSizeShadowView.translatesAutoresizingMaskIntoConstraints = false
        totalContentsSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        adminMenuLabel.translatesAutoresizingMaskIntoConstraints = false
        violationConfirmButton.translatesAutoresizingMaskIntoConstraints = false
        chatConfirmButton.translatesAutoresizingMaskIntoConstraints = false
        UIDInputTxtField.translatesAutoresizingMaskIntoConstraints = false
        createProfileButton.translatesAutoresizingMaskIntoConstraints = false
        dammyChatButton.translatesAutoresizingMaskIntoConstraints = false
        buttonImageView01.translatesAutoresizingMaskIntoConstraints = false
        buttonImageView02.translatesAutoresizingMaskIntoConstraints = false
        buttonImageView03.translatesAutoresizingMaskIntoConstraints = false
        buttonImageView04.translatesAutoresizingMaskIntoConstraints = false
        dammyUpdateButtonShadowView.translatesAutoresizingMaskIntoConstraints = false
        userDammyUpdateResetButton.translatesAutoresizingMaskIntoConstraints = false
    }
    //※レイアウト※
    func autoLayout(){
        ///ラベル群は真ん中からレイアウト決定
        totalChatLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        totalChatLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        totalChatLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.1).isActive = true
        totalChatLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.25).isActive = true
        ///
        subscribeLabel.topAnchor.constraint(equalTo: totalChatLabel.topAnchor).isActive = true
        subscribeLabel.trailingAnchor.constraint(equalTo: totalChatLabel.leadingAnchor, constant: -15).isActive = true
        subscribeLabel.widthAnchor.constraint(equalTo: totalChatLabel.widthAnchor).isActive = true
        subscribeLabel.heightAnchor.constraint(equalTo: totalChatLabel.heightAnchor).isActive = true
        
        totalContentsSizeLabel.topAnchor.constraint(equalTo: totalChatLabel.topAnchor).isActive = true
        totalContentsSizeLabel.widthAnchor.constraint(equalTo: totalChatLabel.widthAnchor).isActive = true
        totalContentsSizeLabel.heightAnchor.constraint(equalTo: totalChatLabel.heightAnchor).isActive = true
        totalContentsSizeLabel.leadingAnchor.constraint(equalTo: totalChatLabel.trailingAnchor, constant: 15).isActive = true
        
        totalChatShadowView.topAnchor.constraint(equalTo: totalChatLabel.topAnchor).isActive = true
        totalChatShadowView.leadingAnchor.constraint(equalTo: totalChatLabel.leadingAnchor).isActive = true
        totalChatShadowView.trailingAnchor.constraint(equalTo: totalChatLabel.trailingAnchor).isActive = true
        totalChatShadowView.bottomAnchor.constraint(equalTo: totalChatLabel.bottomAnchor).isActive = true
        
        subscribeShadowView.topAnchor.constraint(equalTo: subscribeLabel.topAnchor).isActive = true
        subscribeShadowView.leadingAnchor.constraint(equalTo: subscribeLabel.leadingAnchor).isActive = true
        subscribeShadowView.trailingAnchor.constraint(equalTo: subscribeLabel.trailingAnchor).isActive = true
        subscribeShadowView.bottomAnchor.constraint(equalTo: subscribeLabel.bottomAnchor).isActive = true
        
        totalContentsSizeShadowView.topAnchor.constraint(equalTo: totalContentsSizeLabel.topAnchor).isActive = true
        totalContentsSizeShadowView.leadingAnchor.constraint(equalTo: totalContentsSizeLabel.leadingAnchor).isActive = true
        totalContentsSizeShadowView.trailingAnchor.constraint(equalTo: totalContentsSizeLabel.trailingAnchor).isActive = true
        totalContentsSizeShadowView.bottomAnchor.constraint(equalTo: totalContentsSizeLabel.bottomAnchor).isActive = true
        
        adminMenuLabel.topAnchor.constraint(equalTo: totalChatLabel.bottomAnchor, constant: 15).isActive = true
        adminMenuLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
        adminMenuLabel.heightAnchor.constraint(equalTo: totalChatLabel.heightAnchor, multiplier: 0.5).isActive = true
        adminMenuLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        violationConfirmButton.topAnchor.constraint(equalTo: adminMenuLabel.bottomAnchor, constant: 10).isActive = true
        violationConfirmButton.widthAnchor.constraint(equalTo: adminMenuLabel.widthAnchor).isActive = true
        violationConfirmButton.heightAnchor.constraint(equalTo: adminMenuLabel.heightAnchor).isActive = true
        violationConfirmButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        buttonImageView01.topAnchor.constraint(equalTo: violationConfirmButton.topAnchor).isActive = true
        buttonImageView01.widthAnchor.constraint(equalTo: violationConfirmButton.widthAnchor, multiplier: 0.1).isActive = true
        buttonImageView01.heightAnchor.constraint(equalTo: buttonImageView01.widthAnchor).isActive = true
        buttonImageView01.trailingAnchor.constraint(equalTo: violationConfirmButton.trailingAnchor,constant: -5).isActive = true
        
        chatConfirmButton.topAnchor.constraint(equalTo: violationConfirmButton.bottomAnchor, constant: 10).isActive = true
        chatConfirmButton.widthAnchor.constraint(equalTo: violationConfirmButton.widthAnchor).isActive = true
        chatConfirmButton.heightAnchor.constraint(equalTo: violationConfirmButton.heightAnchor).isActive = true
        chatConfirmButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        buttonImageView02.topAnchor.constraint(equalTo: chatConfirmButton.topAnchor).isActive = true
        buttonImageView02.widthAnchor.constraint(equalTo: chatConfirmButton.widthAnchor, multiplier: 0.1).isActive = true
        buttonImageView02.heightAnchor.constraint(equalTo: buttonImageView02.widthAnchor).isActive = true
        buttonImageView02.trailingAnchor.constraint(equalTo: chatConfirmButton.trailingAnchor,constant: -5).isActive = true
        
        UIDInputTxtField.topAnchor.constraint(equalTo: chatConfirmButton.topAnchor).isActive = true
        UIDInputTxtField.widthAnchor.constraint(equalTo: chatConfirmButton.widthAnchor, multiplier: 0.4).isActive = true
        UIDInputTxtField.heightAnchor.constraint(equalTo: chatConfirmButton.heightAnchor).isActive = true
        UIDInputTxtField.trailingAnchor.constraint(equalTo: buttonImageView02.leadingAnchor).isActive = true
        
        createProfileButton.topAnchor.constraint(equalTo: chatConfirmButton.bottomAnchor, constant: 10).isActive = true
        createProfileButton.widthAnchor.constraint(equalTo: chatConfirmButton.widthAnchor).isActive = true
        createProfileButton.heightAnchor.constraint(equalTo: chatConfirmButton.heightAnchor).isActive = true
        createProfileButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        buttonImageView03.topAnchor.constraint(equalTo: createProfileButton.topAnchor).isActive = true
        buttonImageView03.widthAnchor.constraint(equalTo: createProfileButton.widthAnchor, multiplier: 0.1).isActive = true
        buttonImageView03.heightAnchor.constraint(equalTo: buttonImageView03.widthAnchor).isActive = true
        buttonImageView03.trailingAnchor.constraint(equalTo: createProfileButton.trailingAnchor,constant: -5).isActive = true
        
        dammyChatButton.topAnchor.constraint(equalTo: createProfileButton.bottomAnchor, constant: 5).isActive = true
        dammyChatButton.widthAnchor.constraint(equalTo: createProfileButton.widthAnchor).isActive = true
        dammyChatButton.heightAnchor.constraint(equalTo: createProfileButton.heightAnchor).isActive = true
        dammyChatButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        buttonImageView04.topAnchor.constraint(equalTo: dammyChatButton.topAnchor).isActive = true
        buttonImageView04.widthAnchor.constraint(equalTo: dammyChatButton.widthAnchor, multiplier: 0.1).isActive = true
        buttonImageView04.heightAnchor.constraint(equalTo: buttonImageView04.widthAnchor).isActive = true
        buttonImageView04.trailingAnchor.constraint(equalTo: dammyChatButton.trailingAnchor,constant: -5).isActive = true
        
        userDammyUpdateResetButton.topAnchor.constraint(equalTo: dammyChatButton.bottomAnchor, constant: 10).isActive = true
        userDammyUpdateResetButton.trailingAnchor.constraint(equalTo: dammyChatButton.trailingAnchor).isActive = true
        userDammyUpdateResetButton.heightAnchor.constraint(equalTo: dammyChatButton.heightAnchor).isActive = true
        userDammyUpdateResetButton.widthAnchor.constraint(equalTo: dammyChatButton.widthAnchor, multiplier: 0.3).isActive = true
        
        dammyUpdateButtonShadowView.topAnchor.constraint(equalTo: userDammyUpdateResetButton.topAnchor).isActive = true
        dammyUpdateButtonShadowView.leadingAnchor.constraint(equalTo: userDammyUpdateResetButton.leadingAnchor).isActive = true
        dammyUpdateButtonShadowView.trailingAnchor.constraint(equalTo: userDammyUpdateResetButton.trailingAnchor).isActive = true
        dammyUpdateButtonShadowView.bottomAnchor.constraint(equalTo: userDammyUpdateResetButton.bottomAnchor).isActive = true
        
    }
    
}

//ライン引き
extension AdminMenuView {
    ///本文下の枠線を自作
    override func draw(_ rect: CGRect) {
        // UIBezierPath のインスタンス生成
        let line = UIBezierPath();
        // 起点
        line.move(to: CGPoint(x: self.adminMenuLabel.frame.minX, y: self.adminMenuLabel.frame.maxY));
        // 帰着点
        line.addLine(to: CGPoint(x: self.adminMenuLabel.frame.maxX, y: self.adminMenuLabel.frame.maxY));
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
