//
//  SideMenuTableViewCell.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/07.
//

import UIKit
import Lottie

protocol UserListTableViewCellDelegate:AnyObject{
    func likebuttonPushed(CELL:UserListTableViewCell,CELLUSERSTRUCT:RequiredProfileInfoLocalData)
    func profileImageButtonPushed(CELL:UserListTableViewCell,CELLUSERSTRUCT:RequiredProfileInfoLocalData)
}


class UserListTableViewCell: UITableViewCell {
  ///セル自体が持つUID定数（画面には表示させない nillを初期値にしているがControllerから値は代入される）
    var celluserStruct:RequiredProfileInfoLocalData!
    weak var delegate:UserListTableViewCellDelegate?

    ///ライクボタンプッシュ判定
    var likePush:Bool = false {
        willSet {
            if newValue {
                self.LikeButton.isEnabled = false
            } else {
                self.LikeButton.isEnabled = true
            }
            likeAnimationSetting(pushValue: newValue)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "UserListTableViewCell")
        self.backgroundColor = UIColor.white
        autoLayoutSetUp()
        autoLayout()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        ///セルが再利用されることを考慮して遅延実行
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            ///陰影処理
            self.messageLabelBaseView.shadowSetting()
            
            ///フォントサイズ調整
            self.nicknameLabel.font = UIFont.systemFont(ofSize: sizeAdjust.objecFontSizeAutoResize(MaxCharacterDigit: 5, objectWidth: self.nicknameLabel.frame.width))
            self.ageTextView.font = UIFont.systemFont(ofSize: sizeAdjust.objecFontSizeAutoResize(MaxCharacterDigit: 3, objectWidth: self.ageTextView.frame.width))
            self.areaTextView.font = UIFont.systemFont(ofSize: sizeAdjust.objecFontSizeAutoResize(MaxCharacterDigit: 3, objectWidth: self.areaTextView.frame.width))
            self.loginTimeView.font = UIFont.systemFont(ofSize: sizeAdjust.objecFontSizeAutoResize(MaxCharacterDigit: 3, objectWidth: self.loginTimeView.frame.width))
        }

    }

    ///layoutSubviewsの中で下記の処理を書くと何故か        returnUIButton.titleLabel?.adjustsFontSizeToFitWidth = trueを追記した際に
    ///layoutSubviews内でのbounds.size.widthが  ０.０になってレイアウト変更が適用されなくなるバグがある。
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.width/2
    }
    
    ///プロフィール画像View
    let profileImageView:UIImageView = {
        let returnUIImageView = UIImageView()
        returnUIImageView.layer.borderWidth = 1
        returnUIImageView.clipsToBounds = true
        returnUIImageView.layer.borderColor = UIColor.gray.cgColor
        returnUIImageView.image = UIImage(named: "InitIMage")
        return returnUIImageView
    }()
    
    ///性別画像View
    let genderImageView:UIImageView = {
        let returnUIImageView = UIImageView()
        returnUIImageView.clipsToBounds = true
        returnUIImageView.backgroundColor = .clear
        return returnUIImageView
    }()
    
    ///年齢テキストView
    let ageTextView:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.center
        return returnLabel
    }()
    
    ///住まいテキストView
    let areaTextView:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.center
        return returnLabel
    }()
    ///ログイン時間View
    let loginTimeView:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.center
        return returnLabel
    }()
    
    ///プロフィールボタン
    let profileImageButton:UIButton = {
        let returnUIButton = UIButton()
        returnUIButton.addTarget(self, action: #selector(profileImageButtonPush), for: .touchUpInside)
        returnUIButton.backgroundColor = .clear
        return returnUIButton
    }()
    
    //ニックネームラベル
    let nicknameLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .black
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        return returnLabel
    }()
    ///最新メッセージラベル
    let aboutMessage:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    ///メッセージラベルベースUIVIEW
    let messageLabelBaseView:ShadowBaseView = ShadowBaseView()
    
    ///ライクボタン用ImageView
    let ImageView:LottieAnimationView = {
        var targetAnimation = LottieAnimation.named("star-smash")
        var returnImageView = LottieAnimationView()
        returnImageView.animation = targetAnimation
        returnImageView.contentMode = .scaleAspectFit
        return returnImageView
    }()
    
    ///ライクボタン
    let LikeButton:UIButton = {
        let returnUIButton = UIButton()
        returnUIButton.addTarget(self, action: #selector(likebuttonPushed), for: .touchUpInside)
        returnUIButton.backgroundColor = .clear
        
        return returnUIButton
    }()

    @objc func likebuttonPushed(){
        delegate?.likebuttonPushed(CELL: self, CELLUSERSTRUCT: celluserStruct)
    }
    
    @objc func profileImageButtonPush() {
        delegate?.profileImageButtonPushed(CELL: self, CELLUSERSTRUCT: celluserStruct)
    }


    func nickNameSetCell(Item: String) {
        self.nicknameLabel.text = Item
    }
    
    func aboutMessageSetCell(Item:String) {
        self.aboutMessage.text = Item
    }
    
    func genderImageSetCell(gender:GENDER) {
        self.genderImageView.image = gender.genderImage
    }
    
    func ageSetCell(age:String) {
        self.ageTextView.text = age
    }
    
    func areaSetCell(area:String) {
        self.areaTextView.text = area
    }
    
    func loginTimeSetCell(loginTime:String)
    {
        self.loginTimeView.text = loginTime
    }
//※レイアウト設定※
    func autoLayoutSetUp() {
//        ///各オブジェクトをViewに追加(CELLにオブジェクトを追加する際にはContentViewに追加)
        self.contentView.addSubview(profileImageView)
        self.contentView.addSubview(nicknameLabel)
        self.contentView.addSubview(messageLabelBaseView)
        self.contentView.addSubview(aboutMessage)
        self.contentView.addSubview(ImageView)
        self.contentView.addSubview(profileImageButton)
        self.contentView.addSubview(LikeButton)
        self.contentView.addSubview(genderImageView)
        self.contentView.addSubview(ageTextView)
        self.contentView.addSubview(areaTextView)
        self.contentView.addSubview(loginTimeView)
//        ///UIオートレイアウトと競合させない処理
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabelBaseView.translatesAutoresizingMaskIntoConstraints = false
        aboutMessage.translatesAutoresizingMaskIntoConstraints = false
        ImageView.translatesAutoresizingMaskIntoConstraints = false
        LikeButton.translatesAutoresizingMaskIntoConstraints = false
        profileImageButton.translatesAutoresizingMaskIntoConstraints = false
        genderImageView.translatesAutoresizingMaskIntoConstraints = false
        ageTextView.translatesAutoresizingMaskIntoConstraints = false
        areaTextView.translatesAutoresizingMaskIntoConstraints = false
        loginTimeView.translatesAutoresizingMaskIntoConstraints = false
    }
//※レイアウト※
    func autoLayout() {
        ///プロフィール画像
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2.5).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2.5).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        profileImageView.widthAnchor.constraint(equalTo: self.profileImageView.heightAnchor).isActive = true
        ///プロフィール画像ボタン
        profileImageButton.topAnchor.constraint(equalTo: profileImageView.topAnchor).isActive = true
        profileImageButton.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        profileImageButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor).isActive = true
        profileImageButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor).isActive = true
        //ニックネームラベル
        nicknameLabel.leadingAnchor.constraint(equalTo: self.profileImageView.trailingAnchor, constant: 5).isActive = true
        nicknameLabel.trailingAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        nicknameLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5).isActive = true
        nicknameLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        //性別画像ビュー
        genderImageView.leadingAnchor.constraint(equalTo: nicknameLabel.trailingAnchor, constant: 2).isActive = true
        genderImageView.centerYAnchor.constraint(equalTo: self.nicknameLabel.centerYAnchor).isActive = true
        genderImageView.heightAnchor.constraint(equalTo: self.nicknameLabel.heightAnchor,multiplier: 0.75).isActive = true
        genderImageView.widthAnchor.constraint(equalTo: self.genderImageView.heightAnchor).isActive = true
        //年齢
        ageTextView.leadingAnchor.constraint(equalTo: genderImageView.trailingAnchor, constant: 2).isActive = true
        ageTextView.centerYAnchor.constraint(equalTo: self.genderImageView.centerYAnchor).isActive = true
        ageTextView.heightAnchor.constraint(equalTo: self.nicknameLabel.heightAnchor).isActive = true
        ageTextView.widthAnchor.constraint(equalTo: self.ageTextView.heightAnchor).isActive = true
        //住まい
        areaTextView.leadingAnchor.constraint(equalTo: ageTextView.trailingAnchor, constant: 2).isActive = true
        areaTextView.centerYAnchor.constraint(equalTo: self.ageTextView.centerYAnchor).isActive = true
        areaTextView.heightAnchor.constraint(equalTo: self.nicknameLabel.heightAnchor).isActive = true
        areaTextView.widthAnchor.constraint(equalTo: self.areaTextView.heightAnchor).isActive = true

        ///ライクボタン
        LikeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        LikeButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8).isActive = true
        LikeButton.widthAnchor.constraint(equalTo: self.LikeButton.heightAnchor).isActive = true
        LikeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        ///ライクボタン用イメージビュー
        ImageView.topAnchor.constraint(equalTo: LikeButton.topAnchor,constant: 5).isActive = true
        ImageView.leadingAnchor.constraint(equalTo: LikeButton.leadingAnchor,constant: 5).isActive = true
        ImageView.trailingAnchor.constraint(equalTo: LikeButton.trailingAnchor,constant: -5).isActive = true
        ImageView.bottomAnchor.constraint(equalTo: LikeButton.bottomAnchor,constant: -5).isActive = true
        ///ログイン時間
        loginTimeView.leadingAnchor.constraint(equalTo: areaTextView.trailingAnchor, constant: 2).isActive = true
        loginTimeView.centerYAnchor.constraint(equalTo: self.areaTextView.centerYAnchor).isActive = true
        loginTimeView.heightAnchor.constraint(equalTo: self.nicknameLabel.heightAnchor).isActive = true
        loginTimeView.trailingAnchor.constraint(equalTo: self.LikeButton.leadingAnchor).isActive = true
        
        //最新メッセージラベル
        aboutMessage.leadingAnchor.constraint(equalTo: self.profileImageView.trailingAnchor, constant: 5).isActive = true
        aboutMessage.trailingAnchor.constraint(equalTo: self.LikeButton.leadingAnchor).isActive = true
        aboutMessage.heightAnchor.constraint(equalTo: self.nicknameLabel.heightAnchor).isActive = true
        aboutMessage.topAnchor.constraint(equalTo: self.nicknameLabel.bottomAnchor).isActive = true
        ///メッセージラベルベースビュー
        messageLabelBaseView.topAnchor.constraint(equalTo: self.aboutMessage.topAnchor).isActive = true
        messageLabelBaseView.bottomAnchor.constraint(equalTo: self.aboutMessage.bottomAnchor).isActive = true
        messageLabelBaseView.leadingAnchor.constraint(equalTo: self.aboutMessage.leadingAnchor).isActive = true
        messageLabelBaseView.trailingAnchor.constraint(equalTo: self.aboutMessage.trailingAnchor).isActive = true
     }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension UserListTableViewCell {
    ///lottieアニメーション初期設定
    func likeAnimationSetting(pushValue:Bool) {
        ///初期状態
        if pushValue {
            self.ImageView.currentProgress = 1
        } else {
            self.ImageView.currentProgress = 0.3
        }
    }
    ///lottieアニメーション
    func likeAnimationPlay(targetImageView:LottieAnimationView) {
        targetImageView.play { finished in
        }
    }
}
