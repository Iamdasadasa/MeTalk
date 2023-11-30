//
//  MeTalkProfileChildView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/07.
//

import Foundation
import UIKit

protocol ProfileChildViewDelegate:AnyObject{
    func selfTappedclearButton(tag:Int)
}

class ProfileChildView:UIView{
    ///オブジェクト間の中間値格納変数
    var objectMedianValue:CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        autoLayoutSetUp()
        autoLayout()
    }
    //※layoutSubviews レイアウト描写が更新された後※
    override func layoutSubviews() {
        super.layoutSubviews()
        ///それぞれのフォントサイズを決定
        let titleFontSize = sizeAdjust.objecFontSizeAutoResize(MaxCharacterDigit: 25, objectWidth: TitleLabel.bounds.width)

        let valueFontSize = sizeAdjust.objecFontSizeAutoResize(MaxCharacterDigit: 20, objectWidth: valueLabel.bounds.width)
        
        TitleLabel.font = UIFont.systemFont(ofSize: titleFontSize)
        valueLabel.font = UIFont.systemFont(ofSize: valueFontSize)
        ///自身に陰影をつける（ボタンっぽくする）
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: -2, height: 2)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 2
        ///シャドウパスとして保持
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
    
//※初期化処理※
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//※各定義※
    
    weak var delegate:ProfileChildViewDelegate?
    
    ///ボタン・フィールド定義
    ///自身のViewと同じサイズのボタン
    let selfClearButton:UIButton = {
        let returnUIButton = UIButton()
        returnUIButton.backgroundColor = .clear
        returnUIButton.layer.cornerRadius = 10
        returnUIButton.isEnabled = false
        returnUIButton.addTarget(self, action: #selector(selfClearButtonTapped), for: .touchUpInside)
        return returnUIButton
    }()
    
    @objc func selfClearButtonTapped(){
        delegate?.selfTappedclearButton(tag: self.tag)
    }
    
    ///編集画像
    var editImageView:UIImageView = {
        let returnImageView:UIImageView! = UIImageView()
        returnImageView.image = UIImage(named: "Edit")
        return returnImageView
    }()
    
    ///タイトルラベル
    let TitleLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .gray
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        return returnLabel
    }()
    
    ///値ラベル
    let valueLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = ""
        returnLabel.textColor = .gray
        returnLabel.font = UIFont.boldSystemFont(ofSize: 0.0)
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.numberOfLines = 0
        return returnLabel
    }()
    
    //※レイアウト設定※
    func autoLayoutSetUp() {
        ///各オブジェクトをViewに追加
        addSubview(selfClearButton)
        addSubview(TitleLabel)
        addSubview(valueLabel)

        ///UIオートレイアウトと競合させない処理
        selfClearButton.translatesAutoresizingMaskIntoConstraints = false
        TitleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    //※レイアウト※
    func autoLayout() {
        ///自身のビューと同じサイズのボタンサイズにする
        selfClearButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        selfClearButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        selfClearButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        selfClearButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        ///タイトルラベル
        TitleLabel.topAnchor.constraint(equalTo: self.topAnchor,constant: 5).isActive = true
        TitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        TitleLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.3).isActive = true
        TitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        ///値ラベル
        valueLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -12).isActive = true
        valueLabel.leadingAnchor.constraint(equalTo: self.TitleLabel.leadingAnchor,constant: 20).isActive = true
        valueLabel.widthAnchor.constraint(equalTo: self.TitleLabel.widthAnchor).isActive = true
        valueLabel.heightAnchor.constraint(equalTo: self.TitleLabel.heightAnchor).isActive = true
        
        //編集イメージの追加レイアウト
        ///追加
        addSubview(editImageView)
        ///重複回避
        editImageView.translatesAutoresizingMaskIntoConstraints = false
        ///編集イメージビュー
        editImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.33).isActive = true
        editImageView.widthAnchor.constraint(equalTo: self.editImageView.heightAnchor).isActive = true
        editImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        editImageView.topAnchor.constraint(equalTo: self.TitleLabel.topAnchor).isActive = true

    }
    
}

extension ProfileChildView {
    ///テキストフィールドの枠線を自作
    override func draw(_ rect: CGRect) {
        // UIBezierPath のインスタンス生成
        let line = UIBezierPath();

        // TextFieldの下端から10ポイント下にラインを引く
        let yOffset: CGFloat = 3.0
        ///起点
        line.move(to: CGPoint(x: self.valueLabel.frame.minX, y: self.valueLabel.frame.maxY + yOffset))
        ///帰着点
        line.addLine(to: CGPoint(x: self.valueLabel.frame.maxX, y: self.valueLabel.frame.maxY + yOffset))
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
}


