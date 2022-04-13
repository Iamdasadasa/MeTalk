//
//  SideMenuTableViewCell.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/07.
//

import UIKit

class chatUserListTableViewCell: UITableViewCell {

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
//
//
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

    func setCell(Item: String) {
      self.talkListUserNicknameLabel.text = Item
    }

//※レイアウト設定※
    func autoLayoutSetUp() {
//        ///各オブジェクトをViewに追加(CELLにオブジェクトを追加する際にはContentViewに追加)
        self.contentView.addSubview(talkListUserProfileImageView)
        self.contentView.addSubview(talkListUserNicknameLabel)
//        ///UIオートレイアウトと競合させない処理
        talkListUserProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        talkListUserNicknameLabel.translatesAutoresizingMaskIntoConstraints = false
    }
//※レイアウト※
    func autoLayout() {
        talkListUserProfileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2.5).isActive = true
        talkListUserProfileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2.5).isActive = true
        talkListUserProfileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        talkListUserProfileImageView.widthAnchor.constraint(equalTo: self.talkListUserProfileImageView.heightAnchor).isActive = true

        talkListUserNicknameLabel.leadingAnchor.constraint(equalTo: self.talkListUserProfileImageView.trailingAnchor, constant: 5).isActive = true
        talkListUserNicknameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -80).isActive = true
        talkListUserNicknameLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        talkListUserNicknameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
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
