//
//  MeTalkProfileView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/02.
//

import Foundation
import UIKit

protocol MeTalkProfileViewDelegate:AnyObject{
    func signoutButtonTappedDelegate()
    func profileImageButtonTappedDelegate()
}

class  MeTalkProfileView:UIView{
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
    
    weak var delegate:MeTalkProfileViewDelegate?
    
    ///ボタン・フィールド定義

    //✨✨✨✨✨✨テストログアウトボタン✨✨✨✨✨
    let signoutButton:UIButton = {
        let returnUIButton = UIButton()
        returnUIButton.backgroundColor = .orange
        returnUIButton.layer.cornerRadius = 10.0
        returnUIButton.setTitle("ログアウト", for: .normal)
        returnUIButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return returnUIButton
    }()
    
    ///ログアウトボタンタップ押下時の挙動
    @objc func logoutButtonTapped(){
        delegate?.signoutButtonTappedDelegate()
        
    }
    ///プロフィール画像ボタン
    let profileImageButton:UIButton = {
        let returnUIButton = UIButton()
        returnUIButton.layer.cornerRadius = 120
        returnUIButton.layer.borderWidth = 1
        returnUIButton.layer.borderColor = UIColor.orange.cgColor

        returnUIButton.addTarget(self, action: #selector(profileImageButtonTapped), for: .touchUpInside)
        return returnUIButton
    }()
    
    @objc func profileImageButtonTapped(){
        delegate?.profileImageButtonTappedDelegate()
    }
    
    
    //※レイアウト設定※
    func autoLayoutSetUp() {
        ///各オブジェクトをViewに追加
        
        addSubview(signoutButton)
        addSubview(profileImageButton)
        //addSubview(placeTextField)


        ///UIオートレイアウトと競合させない処理
        signoutButton.translatesAutoresizingMaskIntoConstraints = false
        profileImageButton.translatesAutoresizingMaskIntoConstraints = false
    }
    //※レイアウト※
    func autoLayout() {
        signoutButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.25).isActive = true
        signoutButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.05).isActive = true
        signoutButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        signoutButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        
        profileImageButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.25).isActive = true
        profileImageButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.25).isActive = true
        profileImageButton.topAnchor.constraint(equalTo: self.signoutButton.topAnchor).isActive = true
        profileImageButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        
    }
}
