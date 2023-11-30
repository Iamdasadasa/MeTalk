//
//  SideMenuTableViewCell.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/07.
//

import UIKit

class ChatUserListTableViewCell: UITableViewCell {

    ///セル自体が持つユーザー情報
    var CellListInfoLocalData:RequiredListInfoLocalData = RequiredListInfoLocalData(targetUID: "", SendID: "", FirstMessage: "", likeButtonFLAG: false, meNickname: "", youNickname: "", DateUpdatedAt: Date(), nortificationIconFlag: false)
    ///メッセージセルの文字数固定値
    var messageDigit = 20
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "chatUserListTableViewCell")
        self.backgroundColor = UIColor.white
        autoLayoutSetUp()
        autoLayout()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        ///フォントサイズ調整
        self.talkListUserNicknameLabel.font = UIFont.systemFont(ofSize: sizeAdjust.objecFontSizeAutoResize(MaxCharacterDigit: 6, objectWidth: self.talkListUserNicknameLabel.frame.width))
        self.talkListUserNewMessage.font = UIFont.systemFont(ofSize: sizeAdjust.objecFontSizeAutoResize(MaxCharacterDigit: messageDigit, objectWidth: self.talkListUserNewMessage.frame.width))
        self.receivedTimeLabel.font = UIFont.systemFont(ofSize: sizeAdjust.objecFontSizeAutoResize(MaxCharacterDigit: 6, objectWidth: self.receivedTimeLabel.frame.width))
    }
//
    ///プロフィール画像ボタン
    let talkListUserProfileImageView:UIImageView = {
        let returnUIImageView = UIImageView()
        returnUIImageView.layer.borderWidth = 1
        returnUIImageView.clipsToBounds = true
        returnUIImageView.layer.borderColor = UIColor.gray.cgColor
        return returnUIImageView
    }()
//ニックネームラベル
    let talkListUserNicknameLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .black
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    ///最新メッセージラベル
    let talkListUserNewMessage:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.adjustsFontSizeToFitWidth = true
        returnLabel.textAlignment = .left
        return returnLabel
    }()
    ///新着通知ベルイメージ
    let nortificationImage:UIImageView = {
        let returnImageView = UIImageView()
        returnImageView.backgroundColor = .clear
        return returnImageView
    }()
    
    ///受信時間表示ラベル
    let receivedTimeLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.center
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
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
        if self.talkListUserNewMessage.text!.count > messageDigit {
            let truncatedText = talkListUserNewMessage.text!.prefix(messageDigit * 2) + "..."
            talkListUserNewMessage.text = String(truncatedText)
            talkListUserNewMessage.numberOfLines = 0 // 改行する。
        } else {
            talkListUserNewMessage.numberOfLines = 1
            
        }

    }
    
    func receivedTimeLabelSetCell(Item:String) {
        self.receivedTimeLabel.text = Item
    }

//※レイアウト設定※
    func autoLayoutSetUp() {
//        ///各オブジェクトをViewに追加(CELLにオブジェクトを追加する際にはContentViewに追加)
        self.contentView.addSubview(talkListUserProfileImageView)
        self.contentView.addSubview(talkListUserNicknameLabel)
        self.contentView.addSubview(talkListUserNewMessage)
        self.contentView.addSubview(nortificationImage)
        self.contentView.addSubview(receivedTimeLabel)
//        ///UIオートレイアウトと競合させない処理
        talkListUserProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        talkListUserNicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        talkListUserNewMessage.translatesAutoresizingMaskIntoConstraints = false
        nortificationImage.translatesAutoresizingMaskIntoConstraints = false
        receivedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
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
        talkListUserNicknameLabel.trailingAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        talkListUserNicknameLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.35).isActive = true
        talkListUserNicknameLabel.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: -5).isActive = true
        //最新メッセージラベル
        talkListUserNewMessage.leadingAnchor.constraint(equalTo: self.talkListUserProfileImageView.trailingAnchor, constant: 5).isActive = true
        talkListUserNewMessage.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.6).isActive = true
        talkListUserNewMessage.topAnchor.constraint(equalTo: talkListUserNicknameLabel.bottomAnchor, constant: 3).isActive = true
        talkListUserNewMessage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3).isActive = true
//        talkListUserNewMessage.heightAnchor.constraint(equalTo: self.talkListUserNicknameLabel.heightAnchor).isActive = true
//        talkListUserNewMessage.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 5).isActive = true

        ///新着通知ベルイメージ
        nortificationImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        nortificationImage.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.25).isActive = true
        nortificationImage.widthAnchor.constraint(equalTo: nortificationImage.heightAnchor).isActive = true
        nortificationImage.leadingAnchor.constraint(equalTo: talkListUserNewMessage.trailingAnchor).isActive = true
        
        ///受信時間表示ラベル
        receivedTimeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -10).isActive = true
        receivedTimeLabel.leadingAnchor.constraint(equalTo: nortificationImage.trailingAnchor).isActive = true
        receivedTimeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true

        receivedTimeLabel.heightAnchor.constraint(equalTo: talkListUserNewMessage.heightAnchor, multiplier: 0.5).isActive = true
        
     }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        ///layoutSubviewsの中で下記の処理を書くと何故か        returnUIButton.titleLabel?.adjustsFontSizeToFitWidth = trueを追記した際に
        ///layoutSubviews内でのbounds.size.widthが  ０.０になってレイアウト変更が適用されなくなるバグがある。
        self.talkListUserProfileImageView.layer.cornerRadius = self.talkListUserProfileImageView.bounds.size.width/2
        // UIBezierPath のインスタンス生成
        let line = UIBezierPath();
        // 起点
        line.move(to: CGPoint(x: self.talkListUserNewMessage.frame.minX, y: self.talkListUserNewMessage.frame.maxY));
        // 帰着点
        line.addLine(to: CGPoint(x: self.talkListUserNewMessage.frame.maxX, y: self.talkListUserNewMessage.frame.maxY));
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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
