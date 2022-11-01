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
    var profileData:[String:Any] = [:]
    var profileImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    ///コードレイアウトで行う場合はLoadView
    override func loadView() {
        self.view = PROFILEVIEW
        self.targetUserInfoDataSetup(userInfoData: profileData)
        
    }
    
}

extension TargetProfileViewController{
    ///各情報のSetUp
    /// - Parameters:
    /// - userInfoData:画面表示の際に取得してきているユーザーデータ
    /// - Returns:
    func targetUserInfoDataSetup(userInfoData:[String:Any]) {

        ///開始日をもってくる際の日付フォーマットの設定
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        let date = userInfoData["createdAt"] as! Date
        ///日付型をStringに変更してラベルにセット
        let userCreatedAtdate:String = dateFormatter.string(from: date)
        self.PROFILEVIEW.startDateInfoLabel.text = userCreatedAtdate
        ///性別を取得。Firebaseでは数値で入っているために数字を判断して性別表示
        switch userInfoData["Sex"] as? Int {
        case 0:
            self.PROFILEVIEW.sexInfoLabel.text = "設定なし"
        case 1:
            self.PROFILEVIEW.sexInfoLabel.text = "男性"
        case 2:
            self.PROFILEVIEW.sexInfoLabel.text = "女性"
        default:break
        }
        ///文字列に改行処理を入れる
        let aboutMeMassageValue = userInfoData["aboutMeMassage"] as? String
        let resultValue:String!
        guard let aboutMeMassageValue = aboutMeMassageValue else {
            return
        }
        if aboutMeMassageValue.count >= 15 {
            resultValue = aboutMeMassageValue.prefix(15) + "\n" + aboutMeMassageValue.suffix(aboutMeMassageValue.count - 15)
            print(resultValue)
        } else {
            resultValue = aboutMeMassageValue
        }
        guard let resultValue = resultValue else {return}
        ///ニックネームのラベルとニックネームの項目にデータセット
        
        self.PROFILEVIEW.nickNameItemView.valueLabel.text = userInfoData["nickname"] as? String
        self.PROFILEVIEW.personalInformationLabel.text = userInfoData["nickname"] as? String
        ///ひとことにデータセット
        self.PROFILEVIEW.AboutMeItemView.valueLabel.text = resultValue
        //年齢にデータセット
        guard let ageTypeInt:Int = userInfoData["age"] as? Int else {
            print("年齢を取得できませんでした。")
            return
        }
        if String(ageTypeInt)  == "0" {
            self.PROFILEVIEW.ageItemView.valueLabel.text = "未設定"
        } else {
            self.PROFILEVIEW.ageItemView.valueLabel.text = String(ageTypeInt)
        }
        
        //出身地にデータセット
        self.PROFILEVIEW.areaItemView.valueLabel.text = userInfoData["area"] as? String
        
        ///画像データセット
        self.PROFILEVIEW.profileImageButton.setImage(userInfoData["profileImageData"] as? UIImage, for: .normal)
    }
    
}
