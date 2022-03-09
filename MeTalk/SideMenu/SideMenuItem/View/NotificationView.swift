//
//  NotificationView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/08.
//

import Foundation
import UIKit

protocol NotificarionViewDelegate:AnyObject{
    
}

class NotificationView:UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        autoLayoutSetUp()
        autoLayout()
    }
//※初期化処理※
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //※各定義※
        ///変数宣言
    weak var delegate:NotificarionViewDelegate?
        ///ボタン・フィールド定義
        ///
        ///通知設定タイトルラベル
    let itemTitleLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = "通知設定"
        returnLabel.textColor = .white
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        return returnLabel
    }()
    
    override func layoutSubviews() {
        ///文字サイズを横幅いっぱいまで拡大
        itemTitleLabel.font = itemTitleLabel.font.withSize(itemTitleLabel.bounds.height)
    }
    //※レイアウト設定※
    func autoLayoutSetUp() {
        addSubview(itemTitleLabel)
        ///UIオートレイアウトと競合させない処理
        itemTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    //レイアウト
    func autoLayout() {
        itemTitleLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
        itemTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        itemTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        itemTitleLabel.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 100).isActive = true
    }
}
