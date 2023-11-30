//
//  SideMenuTableViewCell.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/07.
//

import UIKit

protocol blockListTableViewCellDelegate:AnyObject{
    func blockCanceldTapped(TARGETUID:String?,nickName:String?)
}

class blockListTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "BlockListTableViewCell")
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
            blockCancelButtonBaseView.shadowSetting(offset: .buttomReft)
        }
    }
    
    ///layoutSubviewsの中で下記の処理を書くと何故か        returnUIButton.titleLabel?.adjustsFontSizeToFitWidth = trueを追記した際に
    ///layoutSubviews内でのbounds.size.widthが  ０.０になってレイアウト変更が適用されなくなるバグがある。
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.blockUserProfileImageView.layer.cornerRadius = self.blockUserProfileImageView.bounds.size.width/2
        
    }
    
    var UID:String?
    var nickName:String?
    weak var delegate:blockListTableViewCellDelegate?
    
    ///プロフィール画像ボタン
    let blockUserProfileImageView:UIImageView = {
        let returnUIImageView = UIImageView()
        returnUIImageView.layer.borderWidth = 1
        returnUIImageView.clipsToBounds = true
        returnUIImageView.layer.borderColor = UIColor.gray.cgColor
        return returnUIImageView
    }()
    
    let blockUserNicknameLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    ///メッセージラベルベースUIVIEW
    let blockCancelButtonBaseView:ShadowBaseView = ShadowBaseView()
    
    let blockCancelButton:UIButton = {
        let returnUIButton = UIButton()
        returnUIButton.setTitle("ブロック解除", for: .normal)
        returnUIButton.setTitleColor(.gray, for: .normal)
        returnUIButton.titleLabel?.adjustsFontSizeToFitWidth = true
        returnUIButton.clipsToBounds = true
        returnUIButton.layer.borderColor = UIColor.gray.cgColor
        returnUIButton.addTarget(self, action: #selector(blockCancelButtonTapped), for: .touchUpInside)
        return returnUIButton
    }()
    
    @objc func blockCancelButtonTapped(){
        delegate?.blockCanceldTapped(TARGETUID: UID, nickName: nickName)
    }
    
    func setCell(Item: String) {
      self.blockUserNicknameLabel.text = Item
    }
    
//※レイアウト設定※
    func autoLayoutSetUp() {
        ///各オブジェクトをViewに追加(CELLにオブジェクトを追加する際にはContentViewに追加)
        self.contentView.addSubview(blockUserProfileImageView)
        self.contentView.addSubview(blockUserNicknameLabel)
        self.contentView.addSubview(blockCancelButtonBaseView)
        self.contentView.addSubview(blockCancelButton)
        ///UIオートレイアウトと競合させない処理
        blockUserProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        blockUserNicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        blockCancelButtonBaseView.translatesAutoresizingMaskIntoConstraints = false
        blockCancelButton.translatesAutoresizingMaskIntoConstraints = false
    }
//※レイアウト※
    func autoLayout() {
        blockUserProfileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2.5).isActive = true
        blockUserProfileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2.5).isActive = true
        blockUserProfileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        blockUserProfileImageView.widthAnchor.constraint(equalTo: self.blockUserProfileImageView.heightAnchor).isActive = true
        
        blockUserNicknameLabel.leadingAnchor.constraint(equalTo: self.blockUserProfileImageView.trailingAnchor, constant: 10).isActive = true
        blockUserNicknameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -80).isActive = true
        blockUserNicknameLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blockUserNicknameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        blockCancelButton.leadingAnchor.constraint(equalTo: self.blockUserNicknameLabel.trailingAnchor).isActive = true
        blockCancelButton.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -15).isActive = true
        blockCancelButton.topAnchor.constraint(equalTo: self.topAnchor,constant: 5).isActive = true
        blockCancelButton.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -5).isActive = true
        
        blockCancelButtonBaseView.topAnchor.constraint(equalTo: blockCancelButton.topAnchor).isActive = true
        blockCancelButtonBaseView.bottomAnchor.constraint(equalTo: blockCancelButton.bottomAnchor).isActive = true
        blockCancelButtonBaseView.leftAnchor.constraint(equalTo: blockCancelButton.leftAnchor).isActive = translatesAutoresizingMaskIntoConstraints
        blockCancelButtonBaseView.trailingAnchor.constraint(equalTo: blockCancelButton.trailingAnchor).isActive = true
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
