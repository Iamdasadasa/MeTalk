//
//  chatUserListModel.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/09/08.
//

import Foundation
//このビューコントローラがメインで使用するデータ構造体（Nil無し）
class RequiredListInfoLocalData {
    init(targetUID:String,SendID:String,FirstMessage:String,likeButtonFLAG:Bool,
         meNickname:String,youNickname: String,
         DateUpdatedAt: Date,nortificationIconFlag:Bool){
        self.Required_targetUID = targetUID
        self.Required_SendID = SendID
        self.Required_FirstMessage = FirstMessage
        self.Required_likeButtonFLAG = likeButtonFLAG
        self.Required_meNickname = meNickname
        self.Required_youNickname = youNickname
        self.Required_DateUpdatedAt = DateUpdatedAt
        self.Required_nortificationIconFlag = nortificationIconFlag
        
    }
    var Required_targetUID: String
    var Required_SendID: String
    var Required_FirstMessage: String
    var Required_likeButtonFLAG: Bool = false
    var Required_meNickname: String
    var Required_youNickname: String
    var Required_DateUpdatedAt: Date
    var Required_nortificationIconFlag:Bool
}
