//
//  SideMenuTableViewCell.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/07.
//

import UIKit

class SideMenuTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "SideMenuTableViewCell")
        self.backgroundColor = UIColor.black
        autoLayoutSetUp()
        autoLayout()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let titleLabel1:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
//        returnLabel.font = returnLabel.font.withSize(returnLabel.font.pointSize*3)
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    func setCell(Item: String) {
      self.titleLabel1.text = Item
    }
    
//※レイアウト設定※
    func autoLayoutSetUp() {
        ///各オブジェクトをViewに追加
        addSubview(titleLabel1)
        ///UIオートレイアウトと競合させない処理
        titleLabel1.translatesAutoresizingMaskIntoConstraints = false
    }
//※レイアウト※
    func autoLayout() {
        titleLabel1.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        titleLabel1.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        titleLabel1.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        titleLabel1.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
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
