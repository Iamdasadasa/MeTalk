////
////  MeTalkProfileView.swift
////  MeTalk
////
////  Created by KOJIRO MARUYAMA on 2022/02/02.
////
//
//import Foundation
//import UIKit
//
//protocol TargetProfileViewDelegate:AnyObject {
//    func likebuttonPushed()
//    func talkTransitButtonPushed()
//    func profileImageButtonTapped()
//}
//
//class  TargetProfileView01:UIView{
//    ///遷移元のNabigation BarのButtomAnchor
////    var navigationBottomAnchor:NSLayoutYAxisAnchor
//    
//    let nickNameItemView = ProfileChildView()
//    let AboutMeItemView = ProfileChildView()
//    let ageItemView = ProfileChildView()
//    let areaItemView = ProfileChildView()
//    //※初期化処理※
//    
//     override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.backgroundColor = .black
//         autoLayoutSetUp()
//         autoLayout()
//         viewSetUp()
//         ///ここでは相手のプロフィール表示Viewなので編集可能ImageはRemove
//         nickNameItemView.editImageView.removeFromSuperview()
//         AboutMeItemView.editImageView.removeFromSuperview()
//         ageItemView.editImageView.removeFromSuperview()
//         areaItemView.editImageView.removeFromSuperview()
//         
//     }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    
//
//    
//    //※layoutSubviews レイアウト描写が更新された後※
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        ///プロフィール画像を丸くする処理
//        profileImageButton.layer.cornerRadius = profileImageButton.bounds.height/2
//        
////        ///文字サイズを横幅いっぱいまで拡大
////        profileTitleLabel.font = profileTitleLabel.font.withSize(profileTitleLabel.bounds.height)
////        personalInformationLabel.font = personalInformationLabel.font.withSize(personalInformationLabel.bounds.width * 0.07)
////
////        ///線を引くオブジェクトの中間値の値を取得
////        medianValueGet()
//    }
//    
//
////※各定義※
//    
//    weak var delegate:TargetProfileViewDelegate?
//    
//    ///ボタン・フィールド定義
//    ///プロフィール画像ボタン
//    let profileImageButton:UIButton = {
//        let returnUIButton = UIButton()
//        returnUIButton.layer.borderWidth = 1
//        returnUIButton.clipsToBounds = true
//        returnUIButton.layer.borderColor = UIColor.orange.cgColor
//        returnUIButton.addTarget(self, action: #selector(profileImageButtonTapped), for: .touchUpInside)
//        return returnUIButton
//    }()
//    
//    @objc func profileImageButtonTapped(){
//        delegate?.profileImageButtonTapped()
//    }
//    
//    ///プロフィール名ラベル
//    let profileNameTitleLabel:UILabel = {
//        let returnLabel = UILabel()
//        returnLabel.textColor = .white
//        returnLabel.backgroundColor = .clear
//        returnLabel.textAlignment = NSTextAlignment.left
//        returnLabel.adjustsFontSizeToFitWidth = true
//        return returnLabel
//    }()
//    
//    ///基本情報ラベル
//    let personalInformationLabel:UILabel = {
//        let returnLabel = UILabel()
//        returnLabel.textColor = .white
//        returnLabel.backgroundColor = .clear
//        returnLabel.textAlignment = NSTextAlignment.left
//        returnLabel.adjustsFontSizeToFitWidth = true
//        return returnLabel
//    }()
//    
//    ///プロフィール名ボタン
//    let profileNameButton:UIButton = {
//        let returnUIButton = UIButton()
//        returnUIButton.layer.cornerRadius = 10
//        returnUIButton.layer.borderWidth = 1
//        returnUIButton.clipsToBounds = true
//        returnUIButton.layer.borderColor = UIColor.orange.cgColor
//        return returnUIButton
//    }()
//        
//    ///変更不可情報ラベル
//    let cantBeChangedInfoTitleLabel:UILabel = {
//        let returnLabel = UILabel()
//        returnLabel.text = "基本情報"
//        returnLabel.textColor = .white
//        returnLabel.backgroundColor = .clear
//        returnLabel.textAlignment = NSTextAlignment.left
//        returnLabel.adjustsFontSizeToFitWidth = true
//        return returnLabel
//    }()
//    
//    ///性別ImageView
//    let sexImageView:UIImageView = {
//        let image:UIImage? = UIImage(named: "ManWomanSex")
//        let returnImageView:UIImageView! = UIImageView(image: image)
//
//        return returnImageView
//    }()
//    
//    ///性別ラベル
//    let sexInfoLabel:UILabel = {
//        let returnLabel = UILabel()
//        returnLabel.textColor = .white
//        returnLabel.backgroundColor = .clear
//        returnLabel.textAlignment = NSTextAlignment.center
//        returnLabel.adjustsFontSizeToFitWidth = true
//        return returnLabel
//    }()
//    
//    ///ふぁぼImageView
//    let favImageView:UIImageView = {
//        let image:UIImage? = UIImage(named: "Heart")
//        let returnImageView:UIImageView! = UIImageView(image: image)
//
//        return returnImageView
//    }()
//    
//    ///ふぁぼラベル
//    let favInfoLabel:UILabel = {
//        let returnLabel = UILabel()
//        returnLabel.textColor = .white
//        returnLabel.backgroundColor = .clear
//        returnLabel.textAlignment = NSTextAlignment.center
//        returnLabel.adjustsFontSizeToFitWidth = true
//        return returnLabel
//    }()
//    
//    ///開始日ImageView
//    let startDateImageView:UIImageView = {
//        let image:UIImage? = UIImage(named: "Calender")
//        let returnImageView:UIImageView! = UIImageView(image: image)
//
//        return returnImageView
//    }()
//    
//    ///開始日ラベル
//    let startDateInfoLabel:UILabel = {
//        let returnLabel = UILabel()
//        returnLabel.text = ""
//        returnLabel.textColor = .white
//        returnLabel.backgroundColor = .clear
//        returnLabel.textAlignment = NSTextAlignment.center
//        returnLabel.adjustsFontSizeToFitWidth = true
//        return returnLabel
//    }()
//    
//    ///トーク遷移ボタン
//    let talkTransitButton:UIButton = {
//        let returnButton = UIButton()
//        returnButton.setTitle("トークする", for: .normal)
//        returnButton.setTitleColor(.white, for: .normal)
//        returnButton.titleLabel?.adjustsFontSizeToFitWidth = true
//        returnButton.backgroundColor = .orange
//        returnButton.layer.cornerRadius = 10
//        returnButton.addTarget(self, action: #selector(talkTransitButtonPushed), for: .touchUpInside)
//        return returnButton
//    }()
//    
//    ///ライクボタン用背景View
//    let likeButtonBackGroundView:UIView = {
//        var returnUIView = UIView()
//        returnUIView.backgroundColor = .orange
//        returnUIView.layer.cornerRadius = 10
//        return returnUIView
//    }()
//    
//    ///ライクボタン用ImageView
//    let likeButtonImageView:UIImageView = {
//        var returnImageView = UIImageView()
//        returnImageView.image = UIImage(named: "LIKEBUTTON_IMAGE_NORMAL")
//        return returnImageView
//    }()
//    
//    ///ライクボタン
//    let LikeButton:UIButton = {
//        let returnUIButton = UIButton()
//        returnUIButton.addTarget(self, action: #selector(likebuttonPushed), for: .touchUpInside)
//        returnUIButton.backgroundColor = .clear
//        return returnUIButton
//    }()
//    
//    @objc func talkTransitButtonPushed(){
//        delegate?.talkTransitButtonPushed()
//    }
//    
//    @objc func likebuttonPushed(){
//        delegate?.likebuttonPushed()
//    }
//    
//    //※レイアウト設定※
//    func autoLayoutSetUp() {
//        ///各オブジェクトをViewに追加
//        
//        addSubview(profileImageButton)
//        addSubview(personalInformationLabel)
//        addSubview(cantBeChangedInfoTitleLabel)
//        addSubview(nickNameItemView)
//        addSubview(AboutMeItemView)
//        addSubview(ageItemView)
//        addSubview(areaItemView)
//        addSubview(favImageView)
//        addSubview(favInfoLabel)
//        addSubview(sexImageView)
//        addSubview(startDateImageView)
//        addSubview(sexInfoLabel)
//        addSubview(startDateInfoLabel)
//        addSubview(talkTransitButton)
//        addSubview(likeButtonBackGroundView)
//        addSubview(likeButtonImageView)
//        addSubview(LikeButton)
//
//
//        ///UIオートレイアウトと競合させない処理
//        profileImageButton.translatesAutoresizingMaskIntoConstraints = false
//        personalInformationLabel.translatesAutoresizingMaskIntoConstraints = false
//        cantBeChangedInfoTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        sexImageView.translatesAutoresizingMaskIntoConstraints = false
//        favImageView.translatesAutoresizingMaskIntoConstraints = false
//        startDateImageView.translatesAutoresizingMaskIntoConstraints = false
//        sexInfoLabel.translatesAutoresizingMaskIntoConstraints = false
//        favInfoLabel.translatesAutoresizingMaskIntoConstraints = false
//        startDateInfoLabel.translatesAutoresizingMaskIntoConstraints = false
//        AboutMeItemView.translatesAutoresizingMaskIntoConstraints = false
//        ageItemView.translatesAutoresizingMaskIntoConstraints = false
//        areaItemView.translatesAutoresizingMaskIntoConstraints = false
//        nickNameItemView.translatesAutoresizingMaskIntoConstraints = false
//        talkTransitButton.translatesAutoresizingMaskIntoConstraints = false
//        LikeButton.translatesAutoresizingMaskIntoConstraints = false
//        likeButtonImageView.translatesAutoresizingMaskIntoConstraints = false
//        likeButtonBackGroundView.translatesAutoresizingMaskIntoConstraints = false
//    }
//    //※レイアウト※
//    func autoLayout() {
//        
//        profileImageButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
//        profileImageButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
//        profileImageButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.125).isActive = true
//        profileImageButton.widthAnchor.constraint(equalTo: self.profileImageButton.heightAnchor).isActive = true
//        
//        personalInformationLabel.topAnchor.constraint(equalTo: self.profileImageButton.topAnchor).isActive = true
//        personalInformationLabel.leadingAnchor.constraint(equalTo: self.profileImageButton.trailingAnchor, constant: 10).isActive = true
//        personalInformationLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
//        personalInformationLabel.bottomAnchor.constraint(equalTo: self.profileImageButton.bottomAnchor).isActive = true
//        
//        nickNameItemView.topAnchor.constraint(equalTo: self.profileImageButton.bottomAnchor,constant: 50).isActive = true
//        nickNameItemView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
//        nickNameItemView.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -2.5).isActive = true
//        nickNameItemView.heightAnchor.constraint(equalTo: self.profileImageButton.heightAnchor).isActive = true
//        
//        AboutMeItemView.topAnchor.constraint(equalTo: self.nickNameItemView.topAnchor).isActive = true
//        AboutMeItemView.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: 2.5).isActive = true
//        AboutMeItemView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -5).isActive = true
//        AboutMeItemView.heightAnchor.constraint(equalTo: self.nickNameItemView.heightAnchor).isActive = true
//        
//        ageItemView.topAnchor.constraint(equalTo: self.nickNameItemView.bottomAnchor, constant: 5).isActive = true
//        ageItemView.leadingAnchor.constraint(equalTo: self.nickNameItemView.leadingAnchor).isActive = true
//        ageItemView.trailingAnchor.constraint(equalTo: self.nickNameItemView.trailingAnchor).isActive = true
//        ageItemView.heightAnchor.constraint(equalTo: self.nickNameItemView.heightAnchor).isActive = true
//
//        areaItemView.topAnchor.constraint(equalTo: self.AboutMeItemView.bottomAnchor, constant: 5).isActive = true
//        areaItemView.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: 2.5).isActive = true
//        areaItemView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -5).isActive = true
//        areaItemView.heightAnchor.constraint(equalTo: self.AboutMeItemView.heightAnchor).isActive = true
//        
//        cantBeChangedInfoTitleLabel.topAnchor.constraint(equalTo: self.ageItemView.bottomAnchor, constant: 5).isActive = true
//        cantBeChangedInfoTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
//        cantBeChangedInfoTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
//        cantBeChangedInfoTitleLabel.heightAnchor.constraint(equalTo: self.nickNameItemView.heightAnchor, multiplier: 0.25).isActive = true
//        
//        favImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        favImageView.topAnchor.constraint(equalTo: self.cantBeChangedInfoTitleLabel.bottomAnchor, constant: 5).isActive = true
//        favImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
//        favImageView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
//        
//        favInfoLabel.topAnchor.constraint(equalTo: self.favImageView.bottomAnchor, constant: 1).isActive = true
//        favInfoLabel.widthAnchor.constraint(equalTo: self.favImageView.widthAnchor).isActive = true
//        favInfoLabel.heightAnchor.constraint(equalTo: cantBeChangedInfoTitleLabel.heightAnchor).isActive = true
//        favInfoLabel.leadingAnchor.constraint(equalTo: self.favImageView.leadingAnchor).isActive = true
//        
//        sexImageView.topAnchor.constraint(equalTo: self.favImageView.topAnchor).isActive = true
//        sexImageView.widthAnchor.constraint(equalTo: self.favImageView.widthAnchor).isActive = true
//        sexImageView.heightAnchor.constraint(equalTo: self.favImageView.heightAnchor).isActive = true
//        sexImageView.leadingAnchor.constraint(equalTo: self.cantBeChangedInfoTitleLabel.leadingAnchor).isActive = true
//        
//        sexInfoLabel.topAnchor.constraint(equalTo: self.sexImageView.bottomAnchor, constant: 1).isActive = true
//        sexInfoLabel.widthAnchor.constraint(equalTo: self.sexImageView.widthAnchor).isActive = true
//        sexInfoLabel.heightAnchor.constraint(equalTo: cantBeChangedInfoTitleLabel.heightAnchor).isActive = true
//        sexInfoLabel.leadingAnchor.constraint(equalTo: self.sexImageView.leadingAnchor).isActive = true
//        
//        startDateImageView.topAnchor.constraint(equalTo: self.sexImageView.topAnchor).isActive = true
//        startDateImageView.widthAnchor.constraint(equalTo: self.sexImageView.widthAnchor).isActive = true
//        startDateImageView.heightAnchor.constraint(equalTo: self.sexImageView.heightAnchor).isActive = true
//        startDateImageView.trailingAnchor.constraint(equalTo: self.cantBeChangedInfoTitleLabel.trailingAnchor).isActive = true
//        
//        startDateInfoLabel.topAnchor.constraint(equalTo: self.startDateImageView.bottomAnchor, constant: 1).isActive = true
//        startDateInfoLabel.widthAnchor.constraint(equalTo: self.startDateImageView.widthAnchor).isActive = true
//        startDateInfoLabel.heightAnchor.constraint(equalTo: cantBeChangedInfoTitleLabel.heightAnchor).isActive = true
//        startDateInfoLabel.trailingAnchor.constraint(equalTo: self.startDateImageView.trailingAnchor).isActive = true
//        
//        talkTransitButton.centerXAnchor.constraint(equalTo: sexInfoLabel.trailingAnchor).isActive = true
//        talkTransitButton.widthAnchor.constraint(equalTo: self.favInfoLabel.widthAnchor).isActive = true
//        talkTransitButton.topAnchor.constraint(equalTo: self.favInfoLabel.bottomAnchor, constant: 5).isActive = true
//        talkTransitButton.heightAnchor.constraint(equalTo: self.favInfoLabel.heightAnchor).isActive = true
//        
//        likeButtonBackGroundView.centerXAnchor.constraint(equalTo: startDateInfoLabel.leadingAnchor).isActive = true
//        likeButtonBackGroundView.widthAnchor.constraint(equalTo: self.favInfoLabel.widthAnchor).isActive = true
//        likeButtonBackGroundView.topAnchor.constraint(equalTo: self.favInfoLabel.bottomAnchor, constant: 5).isActive = true
//        likeButtonBackGroundView.heightAnchor.constraint(equalTo: self.favInfoLabel.heightAnchor).isActive = true
//        
//        LikeButton.centerXAnchor.constraint(equalTo: startDateInfoLabel.leadingAnchor).isActive = true
//        LikeButton.widthAnchor.constraint(equalTo: self.favInfoLabel.widthAnchor).isActive = true
//        LikeButton.topAnchor.constraint(equalTo: self.favInfoLabel.bottomAnchor, constant: 5).isActive = true
//        LikeButton.heightAnchor.constraint(equalTo: self.favInfoLabel.heightAnchor).isActive = true
//        
//        likeButtonImageView.centerXAnchor.constraint(equalTo: startDateInfoLabel.leadingAnchor).isActive = true
//        likeButtonImageView.widthAnchor.constraint(equalTo: self.favInfoLabel.heightAnchor).isActive = true
//        likeButtonImageView.heightAnchor.constraint(equalTo: self.favInfoLabel.heightAnchor).isActive = true
//        likeButtonImageView.topAnchor.constraint(equalTo: self.favInfoLabel.bottomAnchor, constant: 5).isActive = true
//        
//
//    }
//}
//
/////Viewセットアップ
//extension TargetProfileView{
//    func viewSetUp(){
//        ///タイトルセットアップ
//        self.nickNameItemView.TitleLabel.text = "ニックネーム"
//        self.AboutMeItemView.TitleLabel.text = "ひとこと"
//        self.ageItemView.TitleLabel.text = "年齢"
//        self.areaItemView.TitleLabel.text = "住まい"
//        ///View判断タグセットアップ
//        self.nickNameItemView.tag = 1
//        self.AboutMeItemView.tag = 2
//        self.ageItemView.tag = 3
//        self.areaItemView.tag = 4
//    }
//    
//}
