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
    ///オブジェクト間の中間値格納変数
    var objectMedianValue:CGFloat?
    
    let nickNameItemView = MeTalkProfileChildView()
    let AboutMeItemView = MeTalkProfileChildView()
    let ageItemView = MeTalkProfileChildView()
    let areaItemView = MeTalkProfileChildView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        autoLayoutSetUp()
        autoLayout()
        viewSetUp()
    }
    
    //※layoutSubviews レイアウト描写が更新された後※
    override func layoutSubviews() {
        super.layoutSubviews()
        ///プロフィール画像を丸くする処理
        profileImageButton.layer.cornerRadius = profileImageButton.bounds.height/2
        
        ///文字サイズを横幅いっぱいまで拡大
        profileTitleLabel.font = profileTitleLabel.font.withSize(profileTitleLabel.bounds.height)
        personalInformationLabel.font = personalInformationLabel.font.withSize(personalInformationLabel.bounds.width * 0.07)
        
        ///線を引くオブジェクトの中間値の値を取得
        medianValueGet()
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
        returnUIButton.titleLabel?.adjustsFontSizeToFitWidth = true
        returnUIButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return returnUIButton
    }()
    
    ///ログアウトボタンタップ押下時の挙動
    @objc func logoutButtonTapped(){
        delegate?.signoutButtonTappedDelegate()
        
    }
    
    ///プロフィールタイトルラベル
    let profileTitleLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = "プロフィール"
        returnLabel.textColor = .white
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    ///プロフィール画像ボタン
    let profileImageButton:UIButton = {
        let returnUIButton = UIButton()
        returnUIButton.layer.cornerRadius = 50
        returnUIButton.layer.borderWidth = 1
        returnUIButton.clipsToBounds = true
        returnUIButton.layer.borderColor = UIColor.orange.cgColor
        returnUIButton.addTarget(self, action: #selector(profileImageButtonTapped), for: .touchUpInside)
        return returnUIButton
    }()
    
    @objc func profileImageButtonTapped(){
        delegate?.profileImageButtonTappedDelegate()
    }
    
    ///プロフィール名ラベル
    let profileNameTitleLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.textColor = .white
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    ///基本情報ラベル
    let personalInformationLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = "10文字でユーザー名"
        returnLabel.textColor = .white
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    ///プロフィール名ボタン
    let profileNameButton:UIButton = {
        let returnUIButton = UIButton()
        returnUIButton.layer.cornerRadius = 10
        returnUIButton.layer.borderWidth = 1
        returnUIButton.clipsToBounds = true
        returnUIButton.layer.borderColor = UIColor.orange.cgColor
        returnUIButton.addTarget(self, action: #selector(profileImageButtonTapped), for: .touchUpInside)
        return returnUIButton
    }()
    
    @objc func profileNameButtonTapped(){
//        delegate?.profileNameButtonTappedDelegate()
    }
    
    ///変更不可情報ラベル
    let cantBeChangedInfoTitleLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = "基本情報"
        returnLabel.textColor = .white
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.left
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    ///性別ImageView
    let sexImageView:UIImageView = {
        let image:UIImage? = UIImage(named: "ManWomanSex")
        let returnImageView:UIImageView! = UIImageView(image: image)

        return returnImageView
    }()
    
    ///性別ラベル
    let sexInfoLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = ""
        returnLabel.textColor = .white
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.center
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    ///ふぁぼImageView
    let favImageView:UIImageView = {
        let image:UIImage? = UIImage(named: "Heart")
        let returnImageView:UIImageView! = UIImageView(image: image)

        return returnImageView
    }()
    
    ///ふぁぼラベル
    let favInfoLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = ""
        returnLabel.textColor = .white
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.center
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    ///開始日ImageView
    let startDateImageView:UIImageView = {
        let image:UIImage? = UIImage(named: "Calender")
        let returnImageView:UIImageView! = UIImageView(image: image)

        return returnImageView
    }()
    
    ///開始日ラベル
    let startDateInfoLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = ""
        returnLabel.textColor = .white
        returnLabel.backgroundColor = .clear
        returnLabel.textAlignment = NSTextAlignment.center
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    //※レイアウト設定※
    func autoLayoutSetUp() {
        ///各オブジェクトをViewに追加
        
        addSubview(signoutButton)
        addSubview(profileImageButton)
        addSubview(profileTitleLabel)
        addSubview(personalInformationLabel)
        addSubview(nickNameItemView)
        addSubview(AboutMeItemView)
        addSubview(ageItemView)
        addSubview(areaItemView)
        addSubview(cantBeChangedInfoTitleLabel)
        addSubview(favImageView)
        addSubview(favInfoLabel)
        addSubview(sexImageView)
        addSubview(startDateImageView)
        addSubview(sexInfoLabel)
        addSubview(startDateInfoLabel)

        ///UIオートレイアウトと競合させない処理
        nickNameItemView.translatesAutoresizingMaskIntoConstraints = false
        signoutButton.translatesAutoresizingMaskIntoConstraints = false
        profileImageButton.translatesAutoresizingMaskIntoConstraints = false
        profileTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        personalInformationLabel.translatesAutoresizingMaskIntoConstraints = false
        AboutMeItemView.translatesAutoresizingMaskIntoConstraints = false
        ageItemView.translatesAutoresizingMaskIntoConstraints = false
        areaItemView.translatesAutoresizingMaskIntoConstraints = false
        cantBeChangedInfoTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sexImageView.translatesAutoresizingMaskIntoConstraints = false
        favImageView.translatesAutoresizingMaskIntoConstraints = false
        startDateImageView.translatesAutoresizingMaskIntoConstraints = false
        sexInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        favInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        startDateInfoLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    //※レイアウト※
    func autoLayout() {
        profileTitleLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        profileTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        profileTitleLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.05).isActive = true
        profileTitleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
        
        profileImageButton.topAnchor.constraint(equalTo: self.profileTitleLabel.bottomAnchor, constant: 25).isActive = true
        profileImageButton.leadingAnchor.constraint(equalTo: self.profileTitleLabel.leadingAnchor).isActive = true
        profileImageButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.125).isActive = true
        profileImageButton.widthAnchor.constraint(equalTo: self.profileImageButton.heightAnchor).isActive = true
        
        signoutButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        signoutButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        signoutButton.heightAnchor.constraint(equalTo: self.profileTitleLabel.heightAnchor).isActive = true
        signoutButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.25).isActive = true
        
        personalInformationLabel.topAnchor.constraint(equalTo: self.profileImageButton.topAnchor).isActive = true
        personalInformationLabel.leadingAnchor.constraint(equalTo: self.profileImageButton.trailingAnchor, constant: 10).isActive = true
        personalInformationLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        personalInformationLabel.bottomAnchor.constraint(equalTo: self.profileImageButton.bottomAnchor).isActive = true
        
        nickNameItemView.topAnchor.constraint(equalTo: self.profileImageButton.bottomAnchor,constant: 50).isActive = true
//        nickNameItemView.leadingAnchor.constraint(equalTo: self.profileImageButton.leadingAnchor).isActive = true
//        nickNameItemView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        nickNameItemView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        nickNameItemView.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -2.5).isActive = true
        nickNameItemView.heightAnchor.constraint(equalTo: self.profileImageButton.heightAnchor).isActive = true
        
        AboutMeItemView.topAnchor.constraint(equalTo: self.nickNameItemView.topAnchor).isActive = true
        AboutMeItemView.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: 2.5).isActive = true
        AboutMeItemView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -5).isActive = true
        AboutMeItemView.heightAnchor.constraint(equalTo: self.nickNameItemView.heightAnchor).isActive = true
        
        ageItemView.topAnchor.constraint(equalTo: self.nickNameItemView.bottomAnchor, constant: 5).isActive = true
        ageItemView.leadingAnchor.constraint(equalTo: self.nickNameItemView.leadingAnchor).isActive = true
        ageItemView.trailingAnchor.constraint(equalTo: self.nickNameItemView.trailingAnchor).isActive = true
        ageItemView.heightAnchor.constraint(equalTo: self.nickNameItemView.heightAnchor).isActive = true

        areaItemView.topAnchor.constraint(equalTo: self.AboutMeItemView.bottomAnchor, constant: 5).isActive = true
        areaItemView.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: 2.5).isActive = true
        areaItemView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -5).isActive = true
        areaItemView.heightAnchor.constraint(equalTo: self.AboutMeItemView.heightAnchor).isActive = true
        
        cantBeChangedInfoTitleLabel.topAnchor.constraint(equalTo: self.ageItemView.bottomAnchor, constant: 5).isActive = true
        cantBeChangedInfoTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        cantBeChangedInfoTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        cantBeChangedInfoTitleLabel.heightAnchor.constraint(equalTo: self.nickNameItemView.heightAnchor, multiplier: 0.25).isActive = true
        
        favImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        favImageView.topAnchor.constraint(equalTo: self.cantBeChangedInfoTitleLabel.bottomAnchor, constant: 5).isActive = true
        favImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
        favImageView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
        
        favInfoLabel.topAnchor.constraint(equalTo: self.favImageView.bottomAnchor, constant: 1).isActive = true
        favInfoLabel.widthAnchor.constraint(equalTo: self.favImageView.widthAnchor).isActive = true
        favInfoLabel.heightAnchor.constraint(equalTo: cantBeChangedInfoTitleLabel.heightAnchor).isActive = true
        favInfoLabel.leadingAnchor.constraint(equalTo: self.favImageView.leadingAnchor).isActive = true
        
        sexImageView.topAnchor.constraint(equalTo: self.favImageView.topAnchor).isActive = true
        sexImageView.widthAnchor.constraint(equalTo: self.favImageView.widthAnchor).isActive = true
        sexImageView.heightAnchor.constraint(equalTo: self.favImageView.heightAnchor).isActive = true
        sexImageView.leadingAnchor.constraint(equalTo: self.cantBeChangedInfoTitleLabel.leadingAnchor).isActive = true
        
        sexInfoLabel.topAnchor.constraint(equalTo: self.sexImageView.bottomAnchor, constant: 1).isActive = true
        sexInfoLabel.widthAnchor.constraint(equalTo: self.sexImageView.widthAnchor).isActive = true
        sexInfoLabel.heightAnchor.constraint(equalTo: cantBeChangedInfoTitleLabel.heightAnchor).isActive = true
        sexInfoLabel.leadingAnchor.constraint(equalTo: self.sexImageView.leadingAnchor).isActive = true
        
        startDateImageView.topAnchor.constraint(equalTo: self.sexImageView.topAnchor).isActive = true
        startDateImageView.widthAnchor.constraint(equalTo: self.sexImageView.widthAnchor).isActive = true
        startDateImageView.heightAnchor.constraint(equalTo: self.sexImageView.heightAnchor).isActive = true
        startDateImageView.trailingAnchor.constraint(equalTo: self.cantBeChangedInfoTitleLabel.trailingAnchor).isActive = true
        
        startDateInfoLabel.topAnchor.constraint(equalTo: self.startDateImageView.bottomAnchor, constant: 1).isActive = true
        startDateInfoLabel.widthAnchor.constraint(equalTo: self.startDateImageView.widthAnchor).isActive = true
        startDateInfoLabel.heightAnchor.constraint(equalTo: cantBeChangedInfoTitleLabel.heightAnchor).isActive = true
        startDateInfoLabel.trailingAnchor.constraint(equalTo: self.startDateImageView.trailingAnchor).isActive = true
    }
}

extension MeTalkProfileView{
    ///プロフィールタイトルラベルとプロフィールボタンの中間の位置を取得
    func medianValueGet(){
        ///プロフィール画像の最大Y座標の最大値からプロフィールボタンのY座標の最小値を減算した値を取得(オブジェクト同士の真ん中の値が取れる)
        self.objectMedianValue = (self.profileImageButton.frame.maxX - self.profileTitleLabel.frame.minX)/2
        ///上に位置するオブジェクトの最小Y座標の値を加算して、適切な位置に持ってくる
        guard let objectMedianValue = self.objectMedianValue else { return }
        self.objectMedianValue = objectMedianValue + self.profileTitleLabel.frame.minY
    }

    override func draw(_ rect: CGRect) {
        // オブジェクト間の直線 -------------------------------------
        guard let objectMedianValue = self.objectMedianValue else { return }
        // UIBezierPath のインスタンス生成
        let line = UIBezierPath();
        // 起点
        line.move(to: CGPoint(x: self.frame.minX, y: objectMedianValue));
        // 帰着点
        line.addLine(to: CGPoint(x: self.frame.maxX, y:objectMedianValue));
        // ラインを結ぶ
        line.close()
        // 色の設定
        UIColor.init(red: 255, green: 255, blue: 255, alpha: 100).setStroke()
        // ライン幅
        line.lineWidth = 1
        // 描画
        line.stroke();
    }
}

///Viewセットアップ
extension MeTalkProfileView{
    func viewSetUp(){
        ///タイトルセットアップ
        self.nickNameItemView.TitleLabel.text = "ニックネーム"
        self.AboutMeItemView.TitleLabel.text = "ひとこと"
        self.ageItemView.TitleLabel.text = "年齢"
        self.areaItemView.TitleLabel.text = "住まい"
        ///View判断タグセットアップ
        self.nickNameItemView.tag = 1
        self.AboutMeItemView.tag = 2
        self.ageItemView.tag = 3
        self.areaItemView.tag = 4
    }
    
}
