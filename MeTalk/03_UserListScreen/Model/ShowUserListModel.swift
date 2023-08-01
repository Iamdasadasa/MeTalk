//
//  ShowUserListViewModel.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/07/11.
//

import Foundation
import UIKit
//このビューコントローラのみで使用するデータ構造体（Nil無し）
class RequiredProfileInfoLocalData {
    init(UID:String,DateCreatedAt:Date,DateUpdatedAt:Date,
         Sex:Int,AboutMeMassage: String,NickName: String,
         Age: Int,Area: String){
        self.Required_UID = UID
        self.Required_DateCreatedAt = DateCreatedAt
        self.Required_DateUpdatedAt = DateUpdatedAt
        self.Required_Sex = Sex
        self.Required_AboutMeMassage = AboutMeMassage
        self.Required_NickName = NickName
        self.Required_Age = Age
        self.Required_Area = Area
    }
    var Required_UID:String
    var Required_DateCreatedAt: Date
    var Required_DateUpdatedAt: Date
    var Required_Sex:Int
    var Required_AboutMeMassage: String
    var Required_NickName: String
    var Required_Age: Int
    var Required_Area: String
    var Required_LikeButtonPushedFLAG:Bool = false
    var Required_LikeButtonPushedDate:Date?
}

struct ImageDataHolder{
    var targetUID:String?
    var UIImage:UIImage?
}
