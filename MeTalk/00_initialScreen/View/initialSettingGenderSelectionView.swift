//
//  initialSettingGenderSelectView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/04/18.
//

import Foundation
import UIKit
class initialSettingGenderSelectionView:UIView {
    
    // アイコンの半径
    let iconRadius: CGFloat = 30

    // アイコンの間隔
    let iconSpacing: CGFloat = 20

    let maleIcon:UIImageView = {
        let maleIcon = UIImageView()
        maleIcon.backgroundColor = .systemPink
        return maleIcon
    }()

    let femaleIcon:UIImageView = {
        let femaleIcon = UIImageView()
        femaleIcon.backgroundColor = .brown
        return femaleIcon
    }()
    
    let noneIcon:UIImageView = {
        let noneIcon = UIImageView()
        noneIcon.backgroundColor = .black
        return noneIcon
    }()

    // ビューの初期化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    // コードから生成されるビューに対応する初期化メソッド
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    // ビューを初期化するメソッド
    func setupView() {

        let angle = CGFloat.pi / 3 // 60度
        
        maleIcon.translatesAutoresizingMaskIntoConstraints = false
        femaleIcon.translatesAutoresizingMaskIntoConstraints = false
        noneIcon.translatesAutoresizingMaskIntoConstraints = false

        // アイコンを円形にする
        maleIcon.layer.cornerRadius = iconRadius
        femaleIcon.layer.cornerRadius = iconRadius
        noneIcon.layer.cornerRadius = iconRadius

        maleIcon.frame.size = CGSize(width: iconRadius, height: iconRadius)
        femaleIcon.frame.size = CGSize(width: iconRadius, height: iconRadius)
        noneIcon.frame.size = CGSize(width: iconRadius, height: iconRadius)

        maleIcon.center = CGPoint(x: bounds.midX + (iconRadius + iconSpacing) * cos(angle), y: bounds.midY - (iconRadius + iconSpacing) * sin(angle))
        femaleIcon.center = CGPoint(x: bounds.midX - (iconRadius + iconSpacing) * cos(angle), y: bounds.midY - (iconRadius + iconSpacing) * sin(angle))
        noneIcon.center = CGPoint(x: bounds.midX, y: bounds.midY + (iconRadius + iconSpacing))

        addSubview(maleIcon)
        addSubview(femaleIcon)
        addSubview(noneIcon)

        // ビューの背景色を設定する
        self.backgroundColor = .clear
        
        print(maleIcon.center)
        

    }
}
