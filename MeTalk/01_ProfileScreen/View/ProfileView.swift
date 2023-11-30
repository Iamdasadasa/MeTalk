//
//  MeTalkProfileView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/02.
//

import Foundation
import UIKit
import Lottie

protocol ProfileViewDelegate:AnyObject{
    func settingButtonTappedDelegate(User:SENDUSER)
    func profileImageButtonTappedDelegate()
    func keyBoardObserverShowDelegate(Top:CGFloat)
    func keyBoardObserverHideDelegate()
}

protocol TargetProfileButtonDelegate:AnyObject {
    func buckButtonTappedDelegate()
    func likePushButtonTappedDelegate()
    func forMessageButtonDelegate()
}

protocol TargetProfileLikeButtonTappedDelegate:AnyObject {
    func likeButtonPushListControllerDelegate()
}

class  ProfileView:UIView{
    ///オブジェクト間の中間値格納変数
    var objectMedianValue:CGFloat?
    let nickNameItemView = ProfileChildView()
    let AboutMeItemView = ProfileChildView()
    let areaItemView = ProfileChildView()
    var TARGETPROFILE:SENDUSER? {
        didSet {
            userForLayoutChange()
            autoLayoutSetUp()
            autoLayout()
            viewSetUp()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
    }
    
    //※layoutSubviews レイアウト描写が更新された後※
    override func layoutSubviews() {
        super.layoutSubviews()
        ///プロフィール画像を丸くする処理
        profileImageButton.layer.cornerRadius = profileImageButton.bounds.height/2
        
        ///文字サイズを横幅いっぱいまで拡大
        profileTitleLabel.font = profileTitleLabel.font.withSize(profileTitleLabel.bounds.height)
        nickNameTopLabel.font = nickNameTopLabel.font.withSize(nickNameTopLabel.bounds.width * 0.07)

        medianValueGet()
        ///Viewに陰影処理
        if TARGETPROFILE == .TARGET {
            forMessageView.shadowSetting(offset: .buttomReft)
            likePushView.shadowSetting(offset: .buttomReft)
        }
    }
    
//※初期化処理※
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//※各定義※
    weak var delegate:ProfileViewDelegate?
    weak var TargetProfileButtonTappedDelegate:TargetProfileButtonDelegate?
    weak var TargetProfileLikeButtonTappedDelegate:TargetProfileLikeButtonTappedDelegate?
    ///ボタン・フィールド定義
    //設定ボタン
    let settingButton:UIButton = {
        let returnUIButton = UIButton()
        returnUIButton.backgroundColor = .clear
        returnUIButton.layer.cornerRadius = 10.0
        returnUIButton.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
        return returnUIButton
    }()
    ///ログアウトボタンタップ押下時の挙動
    @objc func settingButtonTapped(){
        delegate?.settingButtonTappedDelegate(User: TARGETPROFILE!)
    }
    
    ///プロフィールタイトルラベル
    let profileTitleLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = "┃プロフィール"
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    ///プロフィール画像ボタン
    let profileImageButton:UIButton = {
        let returnUIButton = UIButton()
        returnUIButton.layer.borderWidth = 1
        returnUIButton.clipsToBounds = true
        returnUIButton.layer.borderColor = UIColor.gray.cgColor
        returnUIButton.addTarget(self, action: #selector(profileImageButtonTapped), for: .touchUpInside)
        return returnUIButton
    }()

    
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
    
    ///基本情報ラベル
    let basicInfoLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = "┃基本情報"
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    ///年齢ラベル
    let ageInfoLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.center
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    ///年齢
    let ageImageView:UIImageView = {
        let UIimage = UIImage(named: "Birth")
        let returnImageView:UIImageView! = UIImageView(image: UIimage)
        return returnImageView
    }()
    
    ///性別ImageView
    let sexImageView:UIImageView = {
        let returnImageView:UIImageView! = UIImageView()
        return returnImageView
    }()
    
    ///性別ラベル
    let sexInfoLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.center
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    ///ふぁぼImageView
    let favImageView:UIImageView = {
        let image:UIImage? = UIImage(named: "star")
        let returnImageView:UIImageView! = UIImageView(image: image)
        return returnImageView
    }()
    
    ///ふぁぼラベル
    let favInfoLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .gray
        returnLabel.text = "---"
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.center
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    ///開始日ImageView
    let startDateImageView:UIImageView = {
        let image:UIImage? = UIImage(named: "Calender")
        let returnImageView:UIImageView! = UIImageView(image: image)
        return returnImageView
    }()
    
    ///開始日ラベル
    let startDateInfoLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = ""
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.center
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    //以下は自身以外のユーザーを表示する際に描写するボタン群
    ///メッセージ画面遷移View、ボタン、表示ラベル、画像
    let forMessageView = ShadowBaseView()
    let forMessageButton:UIButton = {
        let returnButton = UIButton()
        returnButton.backgroundColor = .clear
        returnButton.addTarget(self, action: #selector(forMessageButtonTapped), for: .touchUpInside)
        return returnButton
    }()
    let forMessageLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.backgroundColor = .clear
        returnLabel.textColor = .gray
        returnLabel.text = "メッセージ"
        returnLabel.textAlignment = NSTextAlignment.center
        return returnLabel
    }()
    let forMessageImageView:UIImageView = {
       let returnImageView = UIImageView()
        returnImageView.image = UIImage(named: "message")
        return returnImageView
    }()
    ///通報Viewと、ボタン、表示ラベル、画像
    let likePushView = ShadowBaseView()
    let likePushButton:UIButton = {
        let returnButton = UIButton()
        returnButton.backgroundColor = .clear
        returnButton.addTarget(self, action: #selector(likePushButtonTapped), for: .touchUpInside)
        return returnButton
    }()
    let likePushLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.backgroundColor = .clear
        returnLabel.textColor = .gray
        returnLabel.text = "送信"
        returnLabel.textAlignment = NSTextAlignment.center
        return returnLabel
    }()
    ///ライクボタン用ImageView
    let likePushImageView:LottieAnimationView = {
        var targetAnimation = LottieAnimation.named("star-smash")
        var returnImageView = LottieAnimationView()
        returnImageView.animation = targetAnimation
        returnImageView.contentMode = .scaleAspectFit
        return returnImageView
    }()
    
    ///バックボタン設定
    let backButton:UIButton = {
        var returnUIButton:UIButton = UIButton()
        returnUIButton.setImage(UIImage(named: "leftArrow"), for: .normal)
        returnUIButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return returnUIButton
    }()
    
    //※レイアウト設定※
    func autoLayoutSetUp() {
        ///各オブジェクトをViewに追加
        addSubview(settingButton)
        addSubview(profileImageButton)
        addSubview(nickNameTopLabel)
        addSubview(nickNameItemView)
        addSubview(AboutMeItemView)
        addSubview(areaItemView)
        addSubview(basicInfoLabel)
        addSubview(favImageView)
        addSubview(favInfoLabel)
        addSubview(ageInfoLabel)
        addSubview(ageImageView)
        addSubview(sexImageView)
        addSubview(startDateImageView)
        addSubview(sexInfoLabel)
        addSubview(startDateInfoLabel)

        ///UIオートレイアウトと競合させない処理

        settingButton.translatesAutoresizingMaskIntoConstraints = false
        profileImageButton.translatesAutoresizingMaskIntoConstraints = false
        nickNameTopLabel.translatesAutoresizingMaskIntoConstraints = false
        AboutMeItemView.translatesAutoresizingMaskIntoConstraints = false
        areaItemView.translatesAutoresizingMaskIntoConstraints = false
        nickNameItemView.translatesAutoresizingMaskIntoConstraints = false
        basicInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        sexImageView.translatesAutoresizingMaskIntoConstraints = false
        favImageView.translatesAutoresizingMaskIntoConstraints = false
        startDateImageView.translatesAutoresizingMaskIntoConstraints = false
        ageInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        ageImageView.translatesAutoresizingMaskIntoConstraints = false
        sexInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        favInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        startDateInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        //自身でない場合
        if TARGETPROFILE == .TARGET {
            ///メッセージ画面遷移Viewとボタン追加
            addSubview(forMessageView)
            addSubview(forMessageLabel)
            addSubview(forMessageImageView)
            addSubview(forMessageButton)
            addSubview(likePushView)
            addSubview(likePushImageView)
            addSubview(likePushLabel)
            addSubview(likePushButton)
            forMessageView.translatesAutoresizingMaskIntoConstraints = false
            forMessageLabel.translatesAutoresizingMaskIntoConstraints = false
            forMessageImageView.translatesAutoresizingMaskIntoConstraints = false
            forMessageButton.translatesAutoresizingMaskIntoConstraints = false
            likePushView.translatesAutoresizingMaskIntoConstraints = false
            likePushImageView.translatesAutoresizingMaskIntoConstraints = false
            likePushLabel.translatesAutoresizingMaskIntoConstraints = false
            likePushButton.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    //※レイアウト※
    func autoLayout() {
        profileImageButton.topAnchor.constraint(equalTo: self.profileTitleLabel.bottomAnchor, constant: 25).isActive = true
        profileImageButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        profileImageButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.125).isActive = true
        profileImageButton.widthAnchor.constraint(equalTo: self.profileImageButton.heightAnchor).isActive = true
        
        settingButton.topAnchor.constraint(equalTo: self.profileTitleLabel.topAnchor).isActive = true
        settingButton.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -10).isActive = true
        settingButton.heightAnchor.constraint(equalTo: self.profileTitleLabel.heightAnchor,multiplier: 0.8).isActive = true
        settingButton.widthAnchor.constraint(equalTo: self.settingButton.heightAnchor).isActive = true
        
        nickNameTopLabel.topAnchor.constraint(equalTo: self.profileImageButton.topAnchor).isActive = true
        nickNameTopLabel.leadingAnchor.constraint(equalTo: self.profileImageButton.trailingAnchor, constant: 10).isActive = true
        nickNameTopLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        nickNameTopLabel.bottomAnchor.constraint(equalTo: self.profileImageButton.bottomAnchor).isActive = true
        
        nickNameItemView.topAnchor.constraint(equalTo: self.profileImageButton.bottomAnchor,constant: 75).isActive = true
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
            
        basicInfoLabel.topAnchor.constraint(equalTo: self.areaItemView.bottomAnchor, constant: 15).isActive = true
        basicInfoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        basicInfoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        basicInfoLabel.heightAnchor.constraint(equalTo: self.nickNameItemView.heightAnchor, multiplier: 0.3).isActive = true
        
        ///下部四つに基本情報
        let constant:CGFloat = 5
        //左側
        sexImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.20).isActive = true
        sexImageView.heightAnchor.constraint(equalTo: self.sexImageView.widthAnchor).isActive = true
        sexImageView.topAnchor.constraint(equalTo: self.basicInfoLabel.bottomAnchor,constant: 15).isActive = true
        sexImageView.trailingAnchor.constraint(equalTo: self.centerXAnchor,constant: -constant).isActive = true

        sexInfoLabel.topAnchor.constraint(equalTo: self.sexImageView.bottomAnchor, constant: 1).isActive = true
        sexInfoLabel.widthAnchor.constraint(equalTo: self.sexImageView.widthAnchor).isActive = true
        sexInfoLabel.heightAnchor.constraint(equalTo: basicInfoLabel.heightAnchor).isActive = true
        sexInfoLabel.leadingAnchor.constraint(equalTo: self.sexImageView.leadingAnchor).isActive = true
        
        ageImageView.widthAnchor.constraint(equalTo: self.sexImageView.widthAnchor).isActive = true
        ageImageView.heightAnchor.constraint(equalTo: self.ageImageView.widthAnchor).isActive = true
        ageImageView.topAnchor.constraint(equalTo: self.sexImageView.topAnchor).isActive = true
        ageImageView.trailingAnchor.constraint(equalTo: self.sexImageView.leadingAnchor,constant: -constant).isActive = true
        
        ageInfoLabel.topAnchor.constraint(equalTo: self.ageImageView.bottomAnchor, constant: 1).isActive = true
        ageInfoLabel.widthAnchor.constraint(equalTo: self.ageImageView.widthAnchor).isActive = true
        ageInfoLabel.heightAnchor.constraint(equalTo: basicInfoLabel.heightAnchor).isActive = true
        ageInfoLabel.leadingAnchor.constraint(equalTo: self.ageImageView.leadingAnchor).isActive = true
        
        //右側
        favImageView.widthAnchor.constraint(equalTo: self.sexImageView.widthAnchor).isActive = true
        favImageView.heightAnchor.constraint(equalTo: self.sexImageView.heightAnchor).isActive = true
        favImageView.topAnchor.constraint(equalTo: self.sexImageView.topAnchor).isActive = true
        favImageView.leadingAnchor.constraint(equalTo: self.centerXAnchor,constant: constant).isActive = true
        
        favInfoLabel.topAnchor.constraint(equalTo: self.favImageView.bottomAnchor, constant: 1).isActive = true
        favInfoLabel.widthAnchor.constraint(equalTo: self.favImageView.widthAnchor).isActive = true
        favInfoLabel.heightAnchor.constraint(equalTo: basicInfoLabel.heightAnchor).isActive = true
        favInfoLabel.leadingAnchor.constraint(equalTo: self.favImageView.leadingAnchor).isActive = true
        
        startDateImageView.widthAnchor.constraint(equalTo: self.favImageView.widthAnchor).isActive = true
        startDateImageView.heightAnchor.constraint(equalTo: self.favImageView.heightAnchor).isActive = true
        startDateImageView.topAnchor.constraint(equalTo: self.favImageView.topAnchor).isActive = true
        startDateImageView.leadingAnchor.constraint(equalTo: self.favImageView.trailingAnchor,constant: constant).isActive = true
        
        startDateInfoLabel.topAnchor.constraint(equalTo: self.startDateImageView.bottomAnchor, constant: 1).isActive = true
        startDateInfoLabel.widthAnchor.constraint(equalTo: self.startDateImageView.widthAnchor).isActive = true
        startDateInfoLabel.heightAnchor.constraint(equalTo: basicInfoLabel.heightAnchor).isActive = true
        startDateInfoLabel.trailingAnchor.constraint(equalTo: self.startDateImageView.trailingAnchor).isActive = true
        
        //自身でない場合
        if TARGETPROFILE == .TARGET {
            let basisView = UIView()
            addSubview(basisView)
            basisView.translatesAutoresizingMaskIntoConstraints = false
            basisView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1).isActive = true
            basisView.heightAnchor.constraint(equalTo: self.nickNameItemView.heightAnchor,multiplier: 0.5).isActive = true
            basisView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            basisView.topAnchor.constraint(equalTo: self.profileImageButton.bottomAnchor, constant: 3).isActive = true
            forMessageView.topAnchor.constraint(equalTo: basisView.topAnchor, constant: 5).isActive = true
            forMessageView.trailingAnchor.constraint(equalTo: basisView.leadingAnchor,constant: -10).isActive = true
            forMessageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.35).isActive = true
            forMessageView.heightAnchor.constraint(equalTo: basisView.heightAnchor).isActive = true
            forMessageImageView.centerYAnchor.constraint(equalTo: forMessageView.centerYAnchor).isActive = true
            forMessageImageView.leadingAnchor.constraint(equalTo: forMessageView.leadingAnchor).isActive = true
            forMessageImageView.heightAnchor.constraint(equalTo: forMessageView.heightAnchor,multiplier: 0.65).isActive = true
            forMessageImageView.widthAnchor.constraint(equalTo: forMessageImageView.heightAnchor).isActive = true
            
            forMessageLabel.topAnchor.constraint(equalTo: forMessageView.topAnchor).isActive = true
            forMessageLabel.trailingAnchor.constraint(equalTo: forMessageView.trailingAnchor).isActive = true
            forMessageLabel.leadingAnchor.constraint(equalTo: forMessageImageView.trailingAnchor,constant: 5).isActive = true
            forMessageLabel.bottomAnchor.constraint(equalTo: forMessageButton.bottomAnchor).isActive = true
            forMessageButton.topAnchor.constraint(equalTo: forMessageView.topAnchor).isActive = true
            forMessageButton.trailingAnchor.constraint(equalTo: forMessageView.trailingAnchor).isActive = true
            forMessageButton.leadingAnchor.constraint(equalTo: forMessageView.leadingAnchor).isActive = true
            forMessageButton.bottomAnchor.constraint(equalTo: forMessageButton.bottomAnchor).isActive = true
            
            likePushView.topAnchor.constraint(equalTo: basisView.topAnchor, constant: 5).isActive = true
            likePushView.leadingAnchor.constraint(equalTo: basisView.trailingAnchor,constant: 10).isActive = true
            likePushView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.35).isActive = true
            likePushView.heightAnchor.constraint(equalTo: basisView.heightAnchor).isActive = true
            
            likePushImageView.centerYAnchor.constraint(equalTo: likePushView.centerYAnchor).isActive = true
            likePushImageView.leadingAnchor.constraint(equalTo: likePushView.leadingAnchor,constant: 10).isActive = true
            likePushImageView.heightAnchor.constraint(equalTo: likePushView.heightAnchor).isActive = true
            likePushImageView.widthAnchor.constraint(equalTo: likePushImageView.heightAnchor).isActive = true
            
            likePushLabel.topAnchor.constraint(equalTo: likePushView.topAnchor).isActive = true
            likePushLabel.trailingAnchor.constraint(equalTo: likePushView.trailingAnchor).isActive = true
            likePushLabel.leadingAnchor.constraint(equalTo: likePushImageView.trailingAnchor).isActive = true
            likePushLabel.bottomAnchor.constraint(equalTo: likePushView.bottomAnchor).isActive = true
            likePushButton.topAnchor.constraint(equalTo: likePushView.topAnchor).isActive = true
            likePushButton.trailingAnchor.constraint(equalTo: likePushView.trailingAnchor).isActive = true
            likePushButton.leadingAnchor.constraint(equalTo: likePushView.leadingAnchor).isActive = true
            likePushButton.bottomAnchor.constraint(equalTo: likePushView.bottomAnchor).isActive = true
        }
    }
}

extension ProfileView{
    ///線を引くX座標の特定
    func medianValueGet(){
        self.objectMedianValue = self.profileTitleLabel.frame.minY * 2
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
extension ProfileView{
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

        ///View判断タグセットアップ
        self.nickNameItemView.tag = 1
        self.AboutMeItemView.tag = 2
        self.areaItemView.tag = 4
    }
    ///表示するユーザーの種類によって画面のレイアウトを変更
    func userForLayoutChange() {
        ///タイトルラベル共通
        addSubview(profileTitleLabel)
        profileTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        if TARGETPROFILE == .SELF {
            ///プロフィールタイトルラベル
            self.profileTitleLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
            self.profileTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
            self.profileTitleLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.05).isActive = true
            self.profileTitleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
            ///ボタン有効化
            buttonsEnable(Enable: true)

        } else if TARGETPROFILE == .TARGET {

            ///バックボタン追加
            addSubview(backButton)
            backButton.translatesAutoresizingMaskIntoConstraints = false
            backButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
            backButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
            backButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.03).isActive = true
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor).isActive = true
            ///バックボタンに合わせたタイトルラベルの位置
            profileTitleLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
            profileTitleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 10).isActive = true
            profileTitleLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.05).isActive = true
            profileTitleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
            ///編集画像を取り除く
            nickNameItemView.editImageView.isHidden = true
            AboutMeItemView.editImageView.isHidden = true
            areaItemView.editImageView.isHidden = true
        }
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
        TargetProfileButtonTappedDelegate?.buckButtonTappedDelegate()
    }
    ///メッセージボタンタップ時
    @objc func forMessageButtonTapped() {
        TargetProfileButtonTappedDelegate?.forMessageButtonDelegate()
    }
    ///ライクボタンタップ時
    @objc func likePushButtonTapped() {
        TargetProfileButtonTappedDelegate?.likePushButtonTappedDelegate()
        TargetProfileLikeButtonTappedDelegate?.likeButtonPushListControllerDelegate()
    }
    ///lottieアニメーション初期設定
    func likeAnimationSetting(pushValue:Bool) {
        ///初期状態
        if pushValue {
            self.likePushImageView.currentProgress = 1
        } else {
            self.likePushImageView.currentProgress = 0.3
        }
    }
    ///lottieアニメーション
    func likeAnimationPlay() {
        likePushImageView.play { finished in
        }
    }
    ///各ボタン有効/無効
    func buttonsEnable(Enable:Bool) {
        ///基本情報ボタン
        self.nickNameItemView.selfClearButton.isEnabled = Enable
        self.AboutMeItemView.selfClearButton.isEnabled = Enable
        self.areaItemView.selfClearButton.isEnabled = Enable

    }
    ///ブロック対応時のレイアウト変更
    func blockingButtonAction(BLOCK:BlockKind) {
        if BLOCK == .IBlocked {
            let attrText1 = NSMutableAttributedString(string: profileTitleLabel.text!)

            attrText1.addAttributes([
                        .foregroundColor: UIColor.red,
                        ], range: NSMakeRange(0, 1))
            
            profileTitleLabel.attributedText = attrText1
        } else {
            let attrText1 = NSMutableAttributedString(string: profileTitleLabel.text!)

            attrText1.addAttributes([
                .foregroundColor: UIColor.gray,
                        ], range: NSMakeRange(0, 1))
            
            profileTitleLabel.attributedText = attrText1
        }
    }
}
