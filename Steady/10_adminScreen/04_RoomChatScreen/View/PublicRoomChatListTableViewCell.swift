//
//  SideMenuTableViewCell.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/12/19.
//

import UIKit

protocol PublicRoomChatListTableViewCellDelegate:AnyObject{
}


class PublicRoomChatListTableViewCell: UITableViewCell {
    var cellHavingRoomType:RoomInfoCommonImmutable!
    weak var delegate:UserListTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "PublicRoomChatListTableViewCell")
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
            self.roomInfoLabelBaseView.shadowSetting(offset: .topRight)
            
            self.flowRoomNameTextLabel.font = UIFont.systemFont(ofSize: sizeAdjust.objecFontSizeAutoResize(MaxCharacterDigit: 15, objectWidth: self.flowRoomNameTextLabel.frame.width))
            self.roomInfoCapacityLabel.font = UIFont.systemFont(ofSize: sizeAdjust.objecFontSizeAutoResize(MaxCharacterDigit: 8, objectWidth: self.roomInfoCapacityLabel.frame.width))
            self.roomInfovailabilityLabel.font = UIFont.systemFont(ofSize: sizeAdjust.objecFontSizeAutoResize(MaxCharacterDigit: 8, objectWidth: self.roomInfovailabilityLabel.frame.width))
        }

    }

    ///layoutSubviewsの中で下記の処理を書くと何故かreturnUIButton.titleLabel?.adjustsFontSizeToFitWidth = trueを追記した際に
    ///layoutSubviews内でのbounds.size.widthが  ０.０になってレイアウト変更が適用されなくなるバグがある。
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        self.roomImageView.layer.cornerRadius = self.roomImageView.bounds.size.width/2
    }
    
    ///ルーム画像View
    let roomImageView:UIImageView = {
        let returnUIImageView = UIImageView()
        returnUIImageView.layer.borderWidth = 1
        returnUIImageView.clipsToBounds = true
        returnUIImageView.layer.borderColor = UIColor.gray.cgColor
        return returnUIImageView
    }()

    ///個別ルーム名テキストラベル
    let flowRoomNameTextLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .black
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        return returnLabel
    }()
    ///ルーム定員数表示ラベル
    let roomInfoCapacityLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.adjustsFontSizeToFitWidth = true
        returnLabel.textAlignment = .center
        return returnLabel
    }()
    
    ///ルーム空室状況
    let roomInfovailabilityLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.adjustsFontSizeToFitWidth = true
        returnLabel.textAlignment = .center
        return returnLabel
    }()
    
    ///影ベースUIVIEW
    let roomInfoLabelBaseView:ShadowBaseView = ShadowBaseView()

    ///空室状況用ImageView
    let AvailabilityImageView:UIImageView = UIImageView()

    ///個別ルーム名変更関数
    func flowRoomNameTextSetCell(text: String) {
        self.flowRoomNameTextLabel.text = text
    }
    
    ///ルーム定員数変更関数
    func roomInfoCapacityTextSetCell(text: String) {
        self.roomInfoCapacityLabel.text = text
    }
    
    ///満員Or空室状況変更関数
    func roomInfoAvailabilityTextSetCell(text: String) {
        self.roomInfovailabilityLabel.text = text
    }
    
    ///満室Or空室状況画像変更関数
    func AvailabilityImageSetCell(Image: UIImage) {
        self.AvailabilityImageView.image = Image
    }
    
    ///ルーム画像変更関数
    func roomImageViewSetCell(Image: UIImage) {
        self.roomImageView.image = Image
    }


    
//※レイアウト設定※
    func autoLayoutSetUp() {
        ///各オブジェクトをViewに追加(CELLにオブジェクトを追加する際にはContentViewに追加)
        self.contentView.addSubview(roomImageView)
        self.contentView.addSubview(roomInfoLabelBaseView)
        self.contentView.addSubview(flowRoomNameTextLabel)
        self.contentView.addSubview(roomInfoCapacityLabel)
        self.contentView.addSubview(roomInfovailabilityLabel)
        self.contentView.addSubview(AvailabilityImageView)
        ///UIオートレイアウトと競合させない処理
        roomImageView.translatesAutoresizingMaskIntoConstraints = false
        roomInfoLabelBaseView.translatesAutoresizingMaskIntoConstraints = false
        flowRoomNameTextLabel.translatesAutoresizingMaskIntoConstraints = false
        roomInfoCapacityLabel.translatesAutoresizingMaskIntoConstraints = false
        roomInfovailabilityLabel.translatesAutoresizingMaskIntoConstraints = false
        AvailabilityImageView.translatesAutoresizingMaskIntoConstraints = false
    }
//※レイアウト※
    func autoLayout() {
        ///ルーム画像
        roomImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2.5).isActive = true
        roomImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2.5).isActive = true
        roomImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        roomImageView.widthAnchor.constraint(equalTo: self.roomImageView.heightAnchor).isActive = true
        
        //ルーム識別名
        flowRoomNameTextLabel.leadingAnchor.constraint(equalTo: self.roomImageView.trailingAnchor, constant: 10).isActive = true
        flowRoomNameTextLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        flowRoomNameTextLabel.heightAnchor.constraint(equalTo: self.heightAnchor,multiplier: 0.4).isActive = true
        flowRoomNameTextLabel.widthAnchor.constraint(equalTo: self.widthAnchor,multiplier: 0.55).isActive = true
        
        //影ベースラベル
        roomInfoLabelBaseView.leadingAnchor.constraint(equalTo: flowRoomNameTextLabel.leadingAnchor).isActive = true
        roomInfoLabelBaseView.trailingAnchor.constraint(equalTo: self.flowRoomNameTextLabel.trailingAnchor).isActive = true
        roomInfoLabelBaseView.topAnchor.constraint(equalTo: self.flowRoomNameTextLabel.bottomAnchor).isActive = true
        roomInfoLabelBaseView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        ///ルーム定員数表示ラベル
        roomInfoCapacityLabel.leadingAnchor.constraint(equalTo: roomInfoLabelBaseView.leadingAnchor).isActive = true
        roomInfoCapacityLabel.widthAnchor.constraint(equalTo: roomInfoLabelBaseView.widthAnchor, multiplier: 0.5).isActive = true
        roomInfoCapacityLabel.topAnchor.constraint(equalTo: roomInfoLabelBaseView.topAnchor).isActive = true
        roomInfoCapacityLabel.bottomAnchor.constraint(equalTo: roomInfoLabelBaseView.bottomAnchor).isActive = true
        ///ルーム空室状況ラベル
        roomInfovailabilityLabel.leadingAnchor.constraint(equalTo: roomInfoCapacityLabel.trailingAnchor).isActive = true
        roomInfovailabilityLabel.widthAnchor.constraint(equalTo: roomInfoLabelBaseView.widthAnchor, multiplier: 0.5).isActive = true
        roomInfovailabilityLabel.topAnchor.constraint(equalTo: roomInfoLabelBaseView.topAnchor).isActive = true
        roomInfovailabilityLabel.bottomAnchor.constraint(equalTo: roomInfoLabelBaseView.bottomAnchor).isActive = true
        ///空室状況画像
        AvailabilityImageView.leadingAnchor.constraint(equalTo: roomInfovailabilityLabel.trailingAnchor, constant: 5).isActive = true
        AvailabilityImageView.topAnchor.constraint(equalTo: self.topAnchor,constant: 2.5).isActive = true
        AvailabilityImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -2.5).isActive = true
        AvailabilityImageView.widthAnchor.constraint(equalTo: AvailabilityImageView.heightAnchor).isActive = true
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
