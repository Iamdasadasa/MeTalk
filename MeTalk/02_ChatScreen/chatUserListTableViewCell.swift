//
//  SideMenuTableViewCell.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/07.
//

import UIKit

class ChatUserListTableViewCell: UITableViewCell {

    
    ///セル自体が持つUID定数（画面には表示させない nillを初期値にしているがControllerから値は代入される）
    var cellUID:String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "chatUserListTableViewCell")
        self.backgroundColor = UIColor.black
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
    ///ライク画像表示View
    let UILikeImageView:UIImageView = {
        let returnImageView = UIImageView()
        returnImageView.backgroundColor = .clear
        returnImageView.alpha = 0
        returnImageView.image = UIImage(named: "LIKEBUTTON_IMAGE_Pushed")
       return returnImageView
    }()
    
    ///プロフィール画像ボタン
    let talkListUserProfileImageView:UIImageView = {
        let returnUIImageView = UIImageView()
        returnUIImageView.layer.borderWidth = 1
        returnUIImageView.clipsToBounds = true
        returnUIImageView.layer.borderColor = UIColor.orange.cgColor
        return returnUIImageView
    }()
//ニックネームラベル
    let talkListUserNicknameLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .white
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
//        returnLabel.font = returnLabel.font.withSize(returnLabel.font.pointSize*3)
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    ///最新メッセージラベル
    let talkListUserNewMessage:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .white
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    ///新着通知ベルイメージ
    let nortificationImage:UIImageView = {
        let returnImageView = UIImageView()
        returnImageView.backgroundColor = .clear
        return returnImageView
    }()
    
    func nortificationImageSetting(){
        self.nortificationImage.image = UIImage(named: "NotificationIcon")
    }
    
    func nortificationImageRemove() {
        self.nortificationImage.image = nil
    }

    func nickNameSetCell(Item: String) {
      self.talkListUserNicknameLabel.text = Item
    }
    
    func newMessageSetCell(Item:String) {
        self.talkListUserNewMessage.text = Item
    }

//※レイアウト設定※
    func autoLayoutSetUp() {
//        ///各オブジェクトをViewに追加(CELLにオブジェクトを追加する際にはContentViewに追加)
        self.contentView.addSubview(talkListUserProfileImageView)
        self.contentView.addSubview(talkListUserNicknameLabel)
        self.contentView.addSubview(talkListUserNewMessage)
        self.contentView.addSubview(nortificationImage)
        self.contentView.addSubview(UILikeImageView)
//        ///UIオートレイアウトと競合させない処理
        talkListUserProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        talkListUserNicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        talkListUserNewMessage.translatesAutoresizingMaskIntoConstraints = false
        nortificationImage.translatesAutoresizingMaskIntoConstraints = false
        UILikeImageView.translatesAutoresizingMaskIntoConstraints = false
    }
//※レイアウト※
    func autoLayout() {
        ///プロフィール画像
        talkListUserProfileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2.5).isActive = true
        talkListUserProfileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2.5).isActive = true
        talkListUserProfileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        talkListUserProfileImageView.widthAnchor.constraint(equalTo: self.talkListUserProfileImageView.heightAnchor).isActive = true
        //ニックネームラベル
        talkListUserNicknameLabel.leadingAnchor.constraint(equalTo: self.talkListUserProfileImageView.trailingAnchor, constant: 5).isActive = true
        talkListUserNicknameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -80).isActive = true
        talkListUserNicknameLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5).isActive = true
        talkListUserNicknameLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        //最新メッセージラベル
        talkListUserNewMessage.leadingAnchor.constraint(equalTo: self.talkListUserProfileImageView.trailingAnchor, constant: 5).isActive = true
        talkListUserNewMessage.trailingAnchor.constraint(equalTo: self.talkListUserNicknameLabel.trailingAnchor).isActive = true
        talkListUserNewMessage.topAnchor.constraint(equalTo: self.talkListUserNicknameLabel.bottomAnchor).isActive = true
        talkListUserNewMessage.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        ///新着通知ベルイメージ
        nortificationImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        nortificationImage.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.25).isActive = true
        nortificationImage.widthAnchor.constraint(equalTo: nortificationImage.heightAnchor).isActive = true
        nortificationImage.leadingAnchor.constraint(equalTo: talkListUserNewMessage.trailingAnchor).isActive = true
        ///ライク画像
        UILikeImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        UILikeImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        UILikeImageView.leadingAnchor.constraint(equalTo: nortificationImage.trailingAnchor).isActive = true
        UILikeImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
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
