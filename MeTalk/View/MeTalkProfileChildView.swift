//
//  MeTalkProfileChildView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/07.
//

import Foundation
import UIKit

protocol MeTalkProfileChildViewDelegate:AnyObject{
    func selfTappedclearButton()
}

class MeTalkProfileChildView:UIView{
    ///オブジェクト間の中間値格納変数
    var objectMedianValue:CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        autoLayoutSetUp()
        autoLayout()
        
    }
    
    //※layoutSubviews レイアウト描写が更新された後※
    override func layoutSubviews() {
        super.layoutSubviews()
        
        TitleLabel.font = TitleLabel.font.withSize(TitleLabel.bounds.width)
        ///valueLabelの値のサイズはTitleLabelの値のサイズの半分
        valueLabel.font = valueLabel.font.withSize(TitleLabel.font.pointSize * 0.5)
    }
    
//※初期化処理※
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//※各定義※
    
    weak var delegate:MeTalkProfileChildViewDelegate?
    
    ///ボタン・フィールド定義

    
    ///自身のViewと同じサイズのボタン
    let selfClearButton:UIButton = {
        let returnUIButton = UIButton()
        returnUIButton.backgroundColor = .orange
        returnUIButton.layer.cornerRadius = 10
        returnUIButton.addTarget(self, action: #selector(selfClearButtonTapped), for: .touchUpInside)
        return returnUIButton
    }()
    
    @objc func selfClearButtonTapped(){
        delegate?.selfTappedclearButton()
    }
    
    ///タイトルラベル
    let TitleLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = "ニックネーム"
        returnLabel.textColor = .white
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    ///値ラベル
    let valueLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = "まだ用意していません値"
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    ///イメージ
    let image:UIImageView = {
        let returnUIImageView = UIImageView()
        return returnUIImageView
    }()
    
    //※レイアウト設定※
    func autoLayoutSetUp() {
        ///各オブジェクトをViewに追加
        addSubview(selfClearButton)
        addSubview(TitleLabel)
        addSubview(valueLabel)
        addSubview(image)

        ///UIオートレイアウトと競合させない処理
        selfClearButton.translatesAutoresizingMaskIntoConstraints = false
        TitleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
    }
    //※レイアウト※
    func autoLayout() {
        ///自身のビューと同じサイズのボタンサイズにする
        selfClearButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        selfClearButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        selfClearButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        selfClearButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        ///タイトルラベル
        TitleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        TitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        TitleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4).isActive = true
        TitleLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.3).isActive = true
        ///値ラベル
        valueLabel.topAnchor.constraint(equalTo: self.TitleLabel.bottomAnchor).isActive = true
        valueLabel.leadingAnchor.constraint(equalTo: self.TitleLabel.leadingAnchor).isActive = true
        valueLabel.widthAnchor.constraint(equalTo: self.TitleLabel.widthAnchor).isActive = true
        valueLabel.heightAnchor.constraint(equalTo: self.TitleLabel.heightAnchor).isActive = true
        
    }
}


