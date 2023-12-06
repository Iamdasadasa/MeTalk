//
//  ShowImageView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/04.
//

import Foundation
import UIKit

class ShowImageView:UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        autoLayoutSetUp()
        autoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///表示するイメージビュー
    let imageView:UIImageView = {
        let returnUIimageView = UIImageView()
        return returnUIimageView
    }()
    
    //※レイアウト設定※
    func autoLayoutSetUp() {
        ///各オブジェクトをViewに追加
        addSubview(imageView)

        ///UIオートレイアウトと競合させない処理
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //※レイアウト※
    func autoLayout() {
        ///イメージビュー
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    }
    
}
