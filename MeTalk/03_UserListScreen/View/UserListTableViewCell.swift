//
//  SideMenuTableViewCell.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/07.
//

import UIKit

protocol UserListTableViewCellDelegate:AnyObject{
    func likebuttonPushed(CELL:UserListTableViewCell,CELLUSERSTRUCT:UserListStruct)
    func profileImageButtonPushed(CELL:UserListTableViewCell,CELLUSERSTRUCT:UserListStruct)
}

class UserListTableViewCell: UITableViewCell {
  ///セル自体が持つUID定数（画面には表示させない nillを初期値にしているがControllerから値は代入される）
    var celluserStruct:UserListStruct?
    weak var delegate:UserListTableViewCellDelegate?
    
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

    }
//
    ///layoutSubviewsの中で下記の処理を書くと何故か        returnUIButton.titleLabel?.adjustsFontSizeToFitWidth = trueを追記した際に
    ///layoutSubviews内でのbounds.size.widthが  ０.０になってレイアウト変更が適用されなくなるバグがある。
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        self.talkListUserProfileImageView.layer.cornerRadius = self.talkListUserProfileImageView.bounds.size.width/2

    }
//
    
    ///プロフィール画像View
    let talkListUserProfileImageView:UIImageView = {
        let returnUIImageView = UIImageView()
        returnUIImageView.layer.borderWidth = 1
        returnUIImageView.clipsToBounds = true
        returnUIImageView.layer.borderColor = UIColor.orange.cgColor
        return returnUIImageView
    }()
    
    
    ///ライクボタン
    let profileImageButton:UIButton = {
        let returnUIButton = UIButton()
        returnUIButton.addTarget(self, action: #selector(profileImageButtonPush), for: .touchUpInside)
        returnUIButton.backgroundColor = .clear
        
        return returnUIButton
    }()
    
    
//ニックネームラベル
    let talkListUserNicknameLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
//        returnLabel.font = returnLabel.font.withSize(returnLabel.font.pointSize*3)
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    ///最新メッセージラベル
    let aboutMessage:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .white
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    ///ライクボタン用ImageView
    let ImageView:UIImageView = {
        var returnImageView = UIImageView()
        
        returnImageView.image = UIImage(named: "LIKEBUTTON_IMAGE_NORMAL")
        
        return returnImageView
    }()
    
    ///ライクボタン
    let LikeButton:UIButton = {
        let returnUIButton = UIButton()
        returnUIButton.addTarget(self, action: #selector(likebuttonPushed), for: .touchUpInside)
        returnUIButton.backgroundColor = .clear
        
        return returnUIButton
    }()
    ///時間表示用VIEW
    let UITextView:UIView = {
        let returnUIVIEW = UIView()
        returnUIVIEW.backgroundColor = .clear
        returnUIVIEW.alpha = 0
        return returnUIVIEW
    }()
    ///時間表示用ラベル
    let UItextLabel:UILabel = {
        let UItextLabel = UILabel()
        UItextLabel.textColor = .white
        return UItextLabel
    }()
    
    @objc func likebuttonPushed(){
        delegate?.likebuttonPushed(CELL: self, CELLUSERSTRUCT: celluserStruct!)
    }
    
    @objc func profileImageButtonPush() {
        delegate?.profileImageButtonPushed(CELL: self, CELLUSERSTRUCT: celluserStruct!)
    }
    
//
//    func nortificationImageSetting(){
//        self.nortificationImage.image = UIImage(named: "NotificationIcon")
//    }
//
//    func nortificationImageRemove() {
//        self.nortificationImage.image = nil
//    }

    func nickNameSetCell(Item: String) {
      self.talkListUserNicknameLabel.text = Item
    }
    
    func aboutMessageSetCell(Item:String) {
        self.aboutMessage.text = Item
    }

//※レイアウト設定※
    func autoLayoutSetUp() {
//        ///各オブジェクトをViewに追加(CELLにオブジェクトを追加する際にはContentViewに追加)
        self.contentView.addSubview(talkListUserProfileImageView)
        self.contentView.addSubview(talkListUserNicknameLabel)
        self.contentView.addSubview(aboutMessage)
        self.contentView.addSubview(ImageView)
        self.contentView.addSubview(profileImageButton)
        self.contentView.addSubview(UITextView)
        self.contentView.addSubview(LikeButton)
        self.UITextView.addSubViewFill(UItextLabel)
//        ///UIオートレイアウトと競合させない処理
        talkListUserProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        talkListUserNicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutMessage.translatesAutoresizingMaskIntoConstraints = false
        ImageView.translatesAutoresizingMaskIntoConstraints = false
        LikeButton.translatesAutoresizingMaskIntoConstraints = false
        UITextView.translatesAutoresizingMaskIntoConstraints = false
        profileImageButton.translatesAutoresizingMaskIntoConstraints = false
    }
//※レイアウト※
    func autoLayout() {
        ///プロフィール画像
        talkListUserProfileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2.5).isActive = true
        talkListUserProfileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2.5).isActive = true
        talkListUserProfileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        talkListUserProfileImageView.widthAnchor.constraint(equalTo: self.talkListUserProfileImageView.heightAnchor).isActive = true
        ///プロフィール画像ボタン
        profileImageButton.topAnchor.constraint(equalTo: talkListUserProfileImageView.topAnchor).isActive = true
        profileImageButton.leadingAnchor.constraint(equalTo: talkListUserProfileImageView.leadingAnchor).isActive = true
        profileImageButton.trailingAnchor.constraint(equalTo: talkListUserProfileImageView.trailingAnchor).isActive = true
        profileImageButton.bottomAnchor.constraint(equalTo: talkListUserProfileImageView.bottomAnchor).isActive = true
        //ニックネームラベル
        talkListUserNicknameLabel.leadingAnchor.constraint(equalTo: self.talkListUserProfileImageView.trailingAnchor, constant: 5).isActive = true
        talkListUserNicknameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -80).isActive = true
        talkListUserNicknameLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5).isActive = true
        talkListUserNicknameLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        //最新メッセージラベル
        aboutMessage.leadingAnchor.constraint(equalTo: self.talkListUserProfileImageView.trailingAnchor, constant: 5).isActive = true
        aboutMessage.trailingAnchor.constraint(equalTo: self.talkListUserNicknameLabel.trailingAnchor).isActive = true
        aboutMessage.topAnchor.constraint(equalTo: self.talkListUserNicknameLabel.bottomAnchor).isActive = true
        aboutMessage.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        ///ライクボタン
        LikeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        LikeButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        LikeButton.bottomAnchor.constraint(equalTo: aboutMessage.bottomAnchor).isActive = true
        LikeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        LikeButton.leadingAnchor.constraint(equalTo: aboutMessage.trailingAnchor).isActive = true
        ///ライクボタン用イメージビュー
        ImageView.topAnchor.constraint(equalTo: LikeButton.topAnchor,constant: 10).isActive = true
        ImageView.leadingAnchor.constraint(equalTo: LikeButton.leadingAnchor,constant: 15).isActive = true
        ImageView.trailingAnchor.constraint(equalTo: LikeButton.trailingAnchor,constant: -15).isActive = true
        ImageView.bottomAnchor.constraint(equalTo: LikeButton.bottomAnchor,constant: -10).isActive = true
        ///残り時間表示テキストビュー
        UITextView.topAnchor.constraint(equalTo: ImageView.topAnchor).isActive = true
        UITextView.leadingAnchor.constraint(equalTo: ImageView.leadingAnchor).isActive = true
        UITextView.trailingAnchor.constraint(equalTo: ImageView.trailingAnchor).isActive = true
        UITextView.bottomAnchor.constraint(equalTo: ImageView.bottomAnchor).isActive = true
        
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
