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
    var profileData:profileInfoLocal
    var profileImage:UIImage
    
    init(profileData:profileInfoLocal,profileImage:UIImage) {
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
    func targetUserInfoDataSetup(userInfoData:profileInfoLocal) {
        ///nil判断&格納
        let date:Date
        let aboutMeMessage:String
        let nickName:String
        let age:Int
        let area:String
        let dateResult = userInfoData.dateBinding(dateVaule: userInfoData.lcl_DateCreatedAt)
        let aboutMeMessageResult = userInfoData.strBinding(strVaule: userInfoData.lcl_AboutMeMassage)
        let nickNameResult = userInfoData.strBinding(strVaule: userInfoData.lcl_NickName)
        let ageResult = userInfoData.intBinding(intVaule: userInfoData.lcl_Age)
        let areaResult = userInfoData.strBinding(strVaule: userInfoData.lcl_Area)
        
        if dateResult.1 == .err,aboutMeMessageResult.1 == .err,nickNameResult.1 == .err,ageResult.1 == .err,areaResult.1 == .err{
            createSheet(callback: {
                return
            }, for: .Alert(title: "データが取得できませんでした", message: "やり直してください", buttonMessage: "OK"), SelfViewController: self)
        }
        ///値格納
        date = dateResult.0
        aboutMeMessage = aboutMeMessageResult.0
        nickName = nickNameResult.0
        age = ageResult.0
        area = areaResult.0

        ///開始日をもってくる際の日付フォーマットの設定
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        dateFormatter.locale = Locale(identifier: "ja_JP")

        ///日付型をStringに変更してラベルにセット
        let userCreatedAtdate:String = dateFormatter.string(from: date)
        self.PROFILEVIEW.startDateInfoLabel.text = userCreatedAtdate
        ///性別を取得。Firebaseでは数値で入っているために数字を判断して性別表示
        switch userInfoData.lcl_Sex {
        case 0:
            self.PROFILEVIEW.sexInfoLabel.text = "設定なし"
        case 1:
            self.PROFILEVIEW.sexInfoLabel.text = "男性"
        case 2:
            self.PROFILEVIEW.sexInfoLabel.text = "女性"
        default:break
        }

        let resultValue:String!

        if aboutMeMessage.count >= 15 {
            resultValue = aboutMeMessage.prefix(15) + "\n" + aboutMeMessage.suffix(aboutMeMessage.count - 15)
        } else {
            resultValue = aboutMeMessage
        }

        ///ニックネームのラベルとニックネームの項目にデータセット
        
        self.PROFILEVIEW.nickNameItemView.valueLabel.text = nickName
        self.PROFILEVIEW.personalInformationLabel.text = nickName
        ///ひとことにデータセット
        self.PROFILEVIEW.AboutMeItemView.valueLabel.text = resultValue
        //年齢にデータセット
        let ageTypeInt:Int = age
        
        if String(ageTypeInt)  == "0" {
            self.PROFILEVIEW.ageItemView.valueLabel.text = "未設定"
        } else {
            self.PROFILEVIEW.ageItemView.valueLabel.text = String(ageTypeInt)
        }
        
        //出身地にデータセット
        self.PROFILEVIEW.areaItemView.valueLabel.text = area
        
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
