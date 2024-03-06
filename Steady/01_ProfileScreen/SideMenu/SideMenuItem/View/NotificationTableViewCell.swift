//
//  SideMenuTableViewCell.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/07.
//

import UIKit

enum nortificationKind {
    case nortification
    case vibration
}

protocol nortificationSettingCellDelegate:AnyObject {
    func nortificationSwitchAction(enable:Bool,Switch:UISwitch)
    func vibrationSwitchAction(enable:Bool)
}

class NotificationTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "NotificationTableViewCell")
        self.backgroundColor = UIColor.white
        autoLayoutSetUp()
        autoLayout()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate:nortificationSettingCellDelegate?
    
    var cellFlag:nortificationKind?
    
    let titleLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    let switchButton:UISwitch = {
       let returnSwitch = UISwitch()
        returnSwitch.isOn = true
        returnSwitch.addTarget(self, action: #selector(changeSwitch), for: UIControl.Event.valueChanged)
        
        return returnSwitch
    }()
    
    @objc func changeSwitch(sender: UISwitch) {

        // UISwitch値を取得
        let onCheck: Bool = sender.isOn
        // UISwitch値を確認
        if onCheck {
            switch cellFlag {
            case .nortification:
                delegate?.nortificationSwitchAction(enable: true, Switch: sender)
            case .vibration:
                delegate?.vibrationSwitchAction(enable: true)
            default:
                return
            }
        } else {
            switch cellFlag {
            case .nortification:
                delegate?.nortificationSwitchAction(enable: false, Switch: sender)
            case .vibration:
                delegate?.vibrationSwitchAction(enable: false)
            default:
                return
            }
        }
    }
    
    func setCell(Item: String) {
      self.titleLabel.text = Item
    }
    
//※レイアウト設定※
    func autoLayoutSetUp() {
        ///各オブジェクトをViewに追加(CELLにオブジェクトを追加する際にはContentViewに追加)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(switchButton)
        ///UIオートレイアウトと競合させない処理
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        switchButton.translatesAutoresizingMaskIntoConstraints = false
    }
//※レイアウト※
    func autoLayout() {
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        switchButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        switchButton.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor).isActive = true
        switchButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
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
