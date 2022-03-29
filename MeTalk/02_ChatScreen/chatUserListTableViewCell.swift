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
        self.backgroundColor = UIColor.white
        autoLayoutSetUp()
        autoLayout()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//    }
//
//    ///layoutSubviewsの中で下記の処理を書くと何故か        returnUIButton.titleLabel?.adjustsFontSizeToFitWidth = trueを追記した際に
//    ///layoutSubviews内でのbounds.size.widthが  ０.０になってレイアウト変更が適用されなくなるバグがある。
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//
//        self.blockUserProfileImageView.layer.cornerRadius = self.blockUserProfileImageView.bounds.size.width/2
//
//    }
//
//
//    ///プロフィール画像ボタン
//    let blockUserProfileImageView:UIImageView = {
//        let returnUIImageView = UIImageView()
//        returnUIImageView.layer.borderWidth = 1
//        returnUIImageView.clipsToBounds = true
//        returnUIImageView.layer.borderColor = UIColor.orange.cgColor
//        return returnUIImageView
//    }()
//
    let blockUserNicknameLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .black
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.text = "ウンチングロケーション"
//        returnLabel.font = returnLabel.font.withSize(returnLabel.font.pointSize*3)
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
//
//    let blockCancelButton:UIButton = {
//        let returnUIButton = UIButton()
//        returnUIButton.setTitle("ブロック解除", for: .normal)
//        returnUIButton.titleLabel?.adjustsFontSizeToFitWidth = true
//        returnUIButton.layer.cornerRadius = 10
//        returnUIButton.layer.borderWidth = 1
//        returnUIButton.clipsToBounds = true
//        returnUIButton.layer.borderColor = UIColor.orange.cgColor
//        returnUIButton.addTarget(self, action: #selector(blockCancelButtonTapped), for: .touchUpInside)
//        return returnUIButton
//    }()
//
//    @objc func blockCancelButtonTapped(){
////        delegate?
//    }
//
//    func setCell(Item: String) {
//      self.blockUserNicknameLabel.text = Item
//    }
//
//※レイアウト設定※
    func autoLayoutSetUp() {
//        ///各オブジェクトをViewに追加(CELLにオブジェクトを追加する際にはContentViewに追加)
//        self.contentView.addSubview(blockUserProfileImageView)
        self.contentView.addSubview(blockUserNicknameLabel)
//        self.contentView.addSubview(blockCancelButton)
//        ///UIオートレイアウトと競合させない処理
//        blockUserProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        blockUserNicknameLabel.translatesAutoresizingMaskIntoConstraints = false
//        blockCancelButton.translatesAutoresizingMaskIntoConstraints = false
    }
//※レイアウト※
    func autoLayout() {
//        blockUserProfileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2.5).isActive = true
//        blockUserProfileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2.5).isActive = true
//        blockUserProfileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
//        blockUserProfileImageView.widthAnchor.constraint(equalTo: self.blockUserProfileImageView.heightAnchor).isActive = true
//
        blockUserNicknameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        blockUserNicknameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -80).isActive = true
        blockUserNicknameLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blockUserNicknameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//
//        blockCancelButton.leadingAnchor.constraint(equalTo: self.blockUserNicknameLabel.trailingAnchor).isActive = true
//        blockCancelButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
//        blockCancelButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        blockCancelButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
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
