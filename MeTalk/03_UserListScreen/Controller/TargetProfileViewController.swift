//
//  Me2TalkUserListViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/02.
//

import Foundation
import UIKit
import SideMenu


class TargetProfileViewController:UIViewController{

    
    ///インスタンス化(Controller)
    var contentVC:UIViewController?
    let SHOWIMAGEVIEWCONTROLLER = ShowImageViewController()
    ///インスタンス化（View）
    let PROFILEVIEW = TargetProfileView()
    ///プロフィール情報を保存する辞書型変数
    var profileData:UserListStruct
    var profileImage:UIImage
    
    init(profileData:UserListStruct,profileImage:UIImage) {
        self.profileData = profileData
        self.profileImage = profileImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    ///コードレイアウトで行う場合はLoadView
    override func loadView() {
        self.view = PROFILEVIEW
        self.targetUserInfoDataSetup(userInfoData: profileData)
        PROFILEVIEW.delegate = self
        
    }
    
}

extension TargetProfileViewController{
    ///各情報のSetUp
    /// - Parameters:
    /// - userInfoData:画面表示の際に取得してきているユーザーデータ
    /// - Returns:
    func targetUserInfoDataSetup(userInfoData:UserListStruct) {

        ///開始日をもってくる際の日付フォーマットの設定
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        let date = userInfoData.createdAt
        ///日付型をStringに変更してラベルにセット
        let userCreatedAtdate:String = dateFormatter.string(from: date)
        self.PROFILEVIEW.startDateInfoLabel.text = userCreatedAtdate
        ///性別を取得。Firebaseでは数値で入っているために数字を判断して性別表示
        switch userInfoData.Sex {
        case 0:
            self.PROFILEVIEW.sexInfoLabel.text = "設定なし"
        case 1:
            self.PROFILEVIEW.sexInfoLabel.text = "男性"
        case 2:
            self.PROFILEVIEW.sexInfoLabel.text = "女性"
        default:break
        }
        ///文字列に改行処理を入れる
        let aboutMeMassageValue = userInfoData.aboutMessage
        let resultValue:String!

        if aboutMeMassageValue.count >= 15 {
            resultValue = aboutMeMassageValue.prefix(15) + "\n" + aboutMeMassageValue.suffix(aboutMeMassageValue.count - 15)
        } else {
            resultValue = aboutMeMassageValue
        }
        guard let resultValue = resultValue else {return}
        ///ニックネームのラベルとニックネームの項目にデータセット
        
        self.PROFILEVIEW.nickNameItemView.valueLabel.text = userInfoData.userNickName
        self.PROFILEVIEW.personalInformationLabel.text = userInfoData.userNickName
        ///ひとことにデータセット
        self.PROFILEVIEW.AboutMeItemView.valueLabel.text = resultValue
        //年齢にデータセット
        let ageTypeInt:Int = userInfoData.Age
        
        if String(ageTypeInt)  == "0" {
            self.PROFILEVIEW.ageItemView.valueLabel.text = "未設定"
        } else {
            self.PROFILEVIEW.ageItemView.valueLabel.text = String(ageTypeInt)
        }
        
        //出身地にデータセット
        self.PROFILEVIEW.areaItemView.valueLabel.text = userInfoData.From
        
        ///画像データセット
        self.PROFILEVIEW.profileImageButton.setImage(profileImage, for: .normal)
    }
    
}

extension TargetProfileViewController: TargetProfileViewDelegate {
    func likebuttonPushed() {
        print("ライクボタンが押下されました")
    }
    
    func talkTransitButtonPushed() {
        print("トーク遷移ボタンが押下されました")
    }
    
    func profileImageButtonTapped() {
        print("プロフィール画像ボタンが押下されました")
    }
}
