//
//  reportUserListTableViewCell.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/10/27.
//

import UIKit
protocol ReportUserListTableViewCellDelegate:AnyObject {
    func warningButtonTappedDelegate(targetCell:ReportUserListTableViewCell)
    func acountFreezeButtonTapped(targetCell:ReportUserListTableViewCell)
    func deleteButtonTapped(targetCell:ReportUserListTableViewCell)
}

class ReportUserListTableViewCell: UITableViewCell {
    //デリゲート変数
    weak var delegate:ReportUserListTableViewCellDelegate?
    var targetUID:String?
    var reportID:String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        autoLayoutSetUp()
        autoLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // プロフィール画像
    let profileImageView: UIImageView = {
        let returnUIImageView = UIImageView()
        returnUIImageView.layer.borderWidth = 1
        returnUIImageView.clipsToBounds = true
        returnUIImageView.layer.borderColor = UIColor.gray.cgColor
        returnUIImageView.image = UIImage(named: "defProfile")
        return returnUIImageView
    }()

    // 上部テキスト
    let topTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // ここでテキストラベルの設定を行う
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()

    // 下部テキスト
    let bottomTextLabel: UILabel = {
        let label = UILabel()
        // ここでテキストラベルの設定を行う
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    // 警告ボタン
    let warningButton: UIButton = {
        let button = UIButton()
        button.setTitle("警告", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.addTarget(self, action: #selector(warningButtonTapped), for: .touchUpInside)
        return button
    }()
    // 凍結ボタン
    let acountFreezeButton: UIButton = {
        let button = UIButton()
        button.setTitle("凍結", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.addTarget(self, action: #selector(acountFreezeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // 削除ボタン
    let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("削除", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    ///警告ボタン押下時の挙動デリゲート
    @objc func warningButtonTapped(_ sender: UIButton){
        self.delegate?.warningButtonTappedDelegate(targetCell: self)
    }
    
    ///凍結ボタン押下時の挙動デリゲート
    @objc func acountFreezeButtonTapped(_ sender: UIButton){
        self.delegate?.acountFreezeButtonTapped(targetCell: self)
    }
    
    ///削除ボタン押下時の挙動デリゲート
    @objc func deleteButtonTapped(_ sender: UIButton){
        self.delegate?.deleteButtonTapped(targetCell: self)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.width/2
    }
    
    func autoLayoutSetUp() {
        // セルのコンテンツビューにサブビューを追加
        contentView.addSubview(profileImageView)
        contentView.addSubview(topTextLabel)
        contentView.addSubview(bottomTextLabel)
        contentView.addSubview(acountFreezeButton)
        contentView.addSubview(warningButton)
        contentView.addSubview(deleteButton)
        
        //競合させない処理
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        topTextLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomTextLabel.translatesAutoresizingMaskIntoConstraints = false
        acountFreezeButton.translatesAutoresizingMaskIntoConstraints = false
        warningButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func autoLayout() {
        //削除ボタン
        deleteButton.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        deleteButton.widthAnchor.constraint(equalTo: topTextLabel.widthAnchor,multiplier: 0.2).isActive = true
        deleteButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        //警告ボタン
        acountFreezeButton.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        acountFreezeButton.widthAnchor.constraint(equalTo: deleteButton.widthAnchor).isActive = true
        acountFreezeButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor,constant: -5).isActive = true
        acountFreezeButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        //凍結ボタン
        warningButton.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        warningButton.widthAnchor.constraint(equalTo: deleteButton.widthAnchor).isActive = true
        warningButton.trailingAnchor.constraint(equalTo: acountFreezeButton.leadingAnchor,constant: -5).isActive = true
        warningButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        ///プロフィール画像
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2.5).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2.5).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        profileImageView.widthAnchor.constraint(equalTo: self.profileImageView.heightAnchor).isActive = true
        
        //上部テキスト
        topTextLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5).isActive = true
        topTextLabel.trailingAnchor.constraint(equalTo: warningButton.leadingAnchor,constant: -5).isActive = true
        topTextLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5).isActive = true
        topTextLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        //下部テキスト
        bottomTextLabel.topAnchor.constraint(equalTo: topTextLabel.bottomAnchor).isActive = true
        bottomTextLabel.leadingAnchor.constraint(equalTo: topTextLabel.leadingAnchor).isActive = true
        bottomTextLabel.trailingAnchor.constraint(equalTo: topTextLabel.trailingAnchor).isActive = true
        bottomTextLabel.heightAnchor.constraint(equalTo: topTextLabel.heightAnchor).isActive = true
        
    }
}
